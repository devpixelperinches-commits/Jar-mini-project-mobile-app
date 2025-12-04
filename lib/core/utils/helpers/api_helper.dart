import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// API response wrapper for type-safe responses
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      data: null,
      message: message,
      success: false,
      statusCode: statusCode,
    );
  }
}

/// Token refresh callback type
typedef RefreshTokenCallback = Future<bool> Function();

/// Enhanced API Helper with automatic token refresh handling
class ApiHelper {
  static RefreshTokenCallback? _refreshTokenCallback;
  static bool _isRefreshing = false;
  static final List<_PendingRequest> _pendingRequests = [];

  /// ✅ Configure the refresh token handler
  /// Call this once during app initialization
  static void configureRefreshToken(RefreshTokenCallback callback) {
    _refreshTokenCallback = callback;
  }

  /// ✅ Handles Dio responses with type-safe return values and auto token refresh
  static Future<ApiResponse<T>> safeApiCall<T>(
    Future<Response> Function() apiCall, {
    String defaultErrorMessage = "Something went wrong, please try again.",
    T Function(dynamic)? parser,
    List<int> successCodes = const [200, 201],
    bool enableAutoRefresh = true,
  }) async {
    try {
      final Response response = await apiCall();

      if (kDebugMode) {
        debugPrint(
          "📥 API RESPONSE (${response.statusCode}): ${response.data}",
        );
      }

      if (successCodes.contains(response.statusCode) && response.data != null) {
        final data = parser != null
            ? parser(response.data)
            : response.data as T;
        final message = _extractMessage(response.data);

        return ApiResponse.success(
          data,
          message: message,
          statusCode: response.statusCode,
        );
      } else {
        final message = _extractMessage(response.data) ?? defaultErrorMessage;
        return ApiResponse.error(message, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("❌ DIO ERROR: ${e.type} - ${e.message}");
      }

      // Handle 401 Unauthorized with token refresh
      if (enableAutoRefresh &&
          e.response?.statusCode == 401 &&
          _refreshTokenCallback != null) {
        if (kDebugMode) {
          debugPrint("🔄 Token expired, attempting refresh...");
        }

        final refreshed = await _handleTokenRefresh();

        if (refreshed) {
          if (kDebugMode) {
            debugPrint("✅ Token refreshed, retrying request...");
          }
          // Retry the original request
          return safeApiCall<T>(
            apiCall,
            defaultErrorMessage: defaultErrorMessage,
            parser: parser,
            successCodes: successCodes,
            enableAutoRefresh: false, // Prevent infinite loop
          );
        } else {
          if (kDebugMode) {
            debugPrint("❌ Token refresh failed");
          }
          return ApiResponse.error(
            'Session expired. Please login again.',
            statusCode: 401,
          );
        }
      }

      return ApiResponse.error(
        _extractDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ UNEXPECTED ERROR: $e");
      }
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// ✅ Handles token refresh with request queuing
  static Future<bool> _handleTokenRefresh() async {
    if (_isRefreshing) {
      // If already refreshing, queue this request
      final completer = Completer<bool>();
      _pendingRequests.add(_PendingRequest(completer));
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final success = await _refreshTokenCallback!();

      // Resolve all pending requests
      for (final request in _pendingRequests) {
        request.completer.complete(success);
      }
      _pendingRequests.clear();

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Token refresh error: $e");
      }

      // Fail all pending requests
      for (final request in _pendingRequests) {
        request.completer.complete(false);
      }
      _pendingRequests.clear();

      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// ✅ Simpler version that throws exceptions (backward compatible)
  static Future<Map<String, dynamic>> safeApiCallLegacy(
    Future<Response> Function() apiCall, {
    String defaultErrorMessage = "Something went wrong, please try again.",
    bool enableAutoRefresh = true,
  }) async {
    try {
      final Response response = await apiCall();

      if (kDebugMode) {
        debugPrint(
          "📥 API RESPONSE (${response.statusCode}): ${response.data}",
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        return response.data is Map<String, dynamic>
            ? response.data
            : {'data': response.data};
      } else {
        final message = _extractMessage(response.data) ?? defaultErrorMessage;
        throw ApiException(message, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Handle 401 with token refresh
      if (enableAutoRefresh &&
          e.response?.statusCode == 401 &&
          _refreshTokenCallback != null) {
        final refreshed = await _handleTokenRefresh();

        if (refreshed) {
          // Retry the original request
          return safeApiCallLegacy(
            apiCall,
            defaultErrorMessage: defaultErrorMessage,
            enableAutoRefresh: false,
          );
        } else {
          throw ApiException(
            'Session expired. Please login again.',
            statusCode: 401,
            dioError: e,
          );
        }
      }

      throw ApiException(
        _extractDioError(e),
        statusCode: e.response?.statusCode,
        dioError: e,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// ✅ Extracts message from response data
  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
    return null;
  }

  /// ✅ Extracts Dio error messages with improved categorization
  static String _extractDioError(DioException e) {
    // Handle response errors
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      // Extract custom error message from response
      if (data is Map) {
        final message = data['message'] ?? data['error'] ?? data['msg'];
        if (message != null) return message.toString();
      }

      // Handle common HTTP status codes
      switch (statusCode) {
        case 400:
          return 'Bad request. Please check your input.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Resource not found.';
        case 429:
          return 'Too many requests. Please try again later.';
        case 500:
          return 'Server error. Please try again later.';
        case 503:
          return 'Service unavailable. Please try again later.';
        default:
          return 'Server error: ${statusCode ?? 'Unknown'}';
      }
    }

    // Handle network/timeout errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet and try again.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';

      case DioExceptionType.badResponse:
        return 'Invalid response from server.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.badCertificate:
        return 'Certificate verification failed.';

      case DioExceptionType.unknown:
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// ✅ Clear any pending requests (useful for logout)
  static void clearPendingRequests() {
    for (final request in _pendingRequests) {
      request.completer.complete(false);
    }
    _pendingRequests.clear();
    _isRefreshing = false;
  }
}

/// Helper class for queuing pending requests during token refresh
class _PendingRequest {
  final Completer<bool> completer;
  _PendingRequest(this.completer);
}

/// Custom exception class for better error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final DioException? dioError;

  ApiException(this.message, {this.statusCode, this.dioError});

  @override
  String toString() => message;

  bool get isNetworkError =>
      dioError?.type == DioExceptionType.connectionError ||
      dioError?.type == DioExceptionType.connectionTimeout;

  bool get isUnauthorized => statusCode == 401;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/// Example 1: Configure refresh token handler (in main.dart or app startup)
/*
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Configure the refresh token handler
  ApiHelper.configureRefreshToken(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return false;
      
      final dio = Dio();
      final response = await dio.post(
        'https://api.example.com/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        
        // Save new tokens
        await prefs.setString('access_token', newAccessToken);
        await prefs.setString('refresh_token', newRefreshToken);
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  });
  
  runApp(MyApp());
}
*/

/// Example 2: Using with auto token refresh
/*
Future<void> fetchProtectedData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  
  final dio = Dio();
  dio.options.headers['Authorization'] = 'Bearer $token';
  
  // If token is expired (401), it will automatically refresh and retry
  final response = await ApiHelper.safeApiCall<Map<String, dynamic>>(
    () => dio.get('/protected/data'),
  );

  if (response.success) {
    print('Data: ${response.data}');
  } else {
    print('Error: ${response.message}');
  }
}
*/

/// Example 3: Dio Interceptor approach (Alternative method)
/*
class AuthInterceptor extends Interceptor {
  final Dio dio;
  
  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      
      if (refreshed) {
        // Retry the request
        final opts = err.requestOptions;
        final prefs = await SharedPreferences.getInstance();
        final newToken = prefs.getString('access_token');
        opts.headers['Authorization'] = 'Bearer $newToken';
        
        try {
          final response = await dio.fetch(opts);
          handler.resolve(response);
          return;
        } catch (e) {
          handler.next(err);
          return;
        }
      }
    }
    
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    // Your refresh token logic here
    return false;
  }
}

// Setup Dio with interceptor
void setupDio() {
  final dio = Dio();
  dio.interceptors.add(AuthInterceptor(dio));
}
*/

/// Example 4: Logout and clear pending requests
/*
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('refresh_token');
  
  // Clear any pending requests
  ApiHelper.clearPendingRequests();
  
  // Navigate to login screen
  // Navigator.pushReplacementNamed(context, '/login');
}
*/
