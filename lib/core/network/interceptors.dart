import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jarpay/core/config/navigation_service.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  AuthInterceptor(this._dio);

  // -------------------------------
  // ON REQUEST
  // -------------------------------
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    debugPrint('📤 REQUEST → ${options.method} ${options.path}');

    // Skip login/register endpoints
    if (_isAuthEndpoint(options.path)) {
      debugPrint('⏭️ Auth endpoint → Skipping token');
      return handler.next(options);
    }

    final token = await SecureStorageService.getToken();

    if (token != null && token.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.trim()}';
      debugPrint('🔑 Token added (${token.length} chars)');
    } else {
      debugPrint('⚠️ No token available');
    }

    return handler.next(options);
  }

  // -------------------------------
  // ON RESPONSE
  // -------------------------------
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Intercept backend token errors inside 200
    if (_isBackendTokenErrorResponse(response)) {
      debugPrint('🚨 Backend reported invalid token (200 response)');
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data["error"],
        ),
      );
    }

    handler.next(response);
  }

  // -------------------------------
  // ON ERROR — HANDLE ALL STATUS CODES
  // -------------------------------
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final message = _extractErrorMessage(err);

    debugPrint('❌ ERROR → Status: $status | Msg: $message');

    // ---------- 401 Unauthorized ----------
    if (status == 401 || _isBackendInvalidToken(err)) {
      debugPrint('🔓 401 → Logging out (Invalid token)');
      NavigationService.showMessage("Session expired. Please login again.");
      await SecureStorageService.clearTokens();
      NavigationService.clearAndGo('/login');
      return handler.next(err);
    }

    // ---------- 403 Forbidden ----------
    if (status == 403) {
      NavigationService.showMessage(
        "Access denied. You don't have permission.",
      );
      return handler.next(err);
    }

    // ---------- 405 Method Not Allowed ----------
    if (status == 405) {
      NavigationService.showMessage("Method not allowed on server.");
      return handler.next(err);
    }

    // ---------- 500 Internal Server Error ----------
    if (status == 500) {
      NavigationService.showMessage("Server error occurred. Try again later.");
      return handler.next(err);
    }

    // ---------- No Internet / Timeout ----------
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      NavigationService.showMessage("Connection timeout. Check your network.");
      return handler.next(err);
    }

    if (err.type == DioExceptionType.connectionError) {
      NavigationService.showMessage("No internet connection.");
      return handler.next(err);
    }

    // ---------- Fallback ----------
    NavigationService.showMessage(message ?? "Unexpected error occurred.");
    return handler.next(err);
  }

  // -------------------------------
  // HELPERS
  // -------------------------------

  bool _isAuthEndpoint(String path) {
    return path.contains('/login') ||
        path.contains('/register') ||
        path.contains('/refresh') ||
        path.contains('/forgot-password');
  }

  bool _isBackendTokenErrorResponse(Response response) {
    if (response.data is! Map) return false;
    final error = (response.data["error"] ?? "").toString().toLowerCase();

    return error.contains("token") &&
        (error.contains("invalid") || error.contains("expired"));
  }

  bool _isBackendInvalidToken(DioException err) {
    try {
      final data = err.response?.data;
      if (data is Map) {
        final error = data["error"]?.toString() ?? "";
        return [
          "Invalid token",
          "Token expired",
          "Authentication failed. Token is invalid or malformed.",
          "Authentication token missing",
        ].contains(error);
      }
    } catch (_) {}
    return false;
  }

  String? _extractErrorMessage(DioException err) {
    try {
      if (err.response?.data is Map) {
        return err.response?.data["error"]?.toString();
      }
    } catch (_) {}
    return err.message;
  }
}
