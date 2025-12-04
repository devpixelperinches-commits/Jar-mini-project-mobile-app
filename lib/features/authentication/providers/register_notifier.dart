import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/core/provider/mfa_provider.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/features/auth/data/auth_repository.dart';
import 'package:jarpay/core/utils/helpers/api_helper.dart';
import 'package:flutter/foundation.dart';

/// Register state model for better type safety
class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? data;
  final bool isSuccess;
  final bool mfaEnabled;

  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.isSuccess = false,
    this.mfaEnabled = false,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? data,
    bool? isSuccess,
    bool? mfaEnabled,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
      isSuccess: isSuccess ?? this.isSuccess,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
    );
  }
}

/// Enhanced Register Notifier Provider
final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>(
      (ref) => RegisterNotifier(ref, AuthRepository()),
    );

/// Enhanced Register Notifier with better error handling and type safety
class RegisterNotifier extends StateNotifier<RegisterState> {
  final Ref ref;
  final AuthRepository _repo;

  RegisterNotifier(this.ref, this._repo) : super(const RegisterState());

  /// ✅ Register user with improved error handling using ApiResponse
  Future<String?> register(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (kDebugMode) {
      debugPrint("📝 Registering user with data: $userData");
    }

    try {
      final response = await _repo.registerUser(userData);

      if (kDebugMode) {
        debugPrint(
          "📥 Register Response: ${response.success ? 'Success' : 'Failed'}",
        );
      }

      // Handle API error response
      if (!response.success) {
        final errorMsg =
            response.message ?? "Registration failed. Please try again.";
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return errorMsg;
      }

      final res = response.data;
      if (res == null) {
        const errorMsg = "Invalid response from server";
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return errorMsg;
      }

      if (kDebugMode) {
        debugPrint("✅ Register Data: $res");
      }

      // Check for explicit error in response data
      if (res['error'] != null) {
        final msg = res['error'].toString();
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return msg;
      }

      // Check status field
      final status = res['status'];
      if (status != null && status != 1) {
        final msg = (res['message'] ?? res['error'] ?? "Registration failed")
            .toString();
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return msg;
      }

      // Extract token (for OTP verification)
      final token = res['data']?['token'] ?? res['token'];
      if (token != null) {
        await _saveTempToken(token);
      }

      // Extract and save MFA status
      final mfa =
          res['data']?['mfaEnabled'] ??
          res['isMFAEnabled'] ??
          res['mfaEnabled'];
      final isMfaEnabled = _parseMfaStatus(mfa);

      await _updateMfaState(isMfaEnabled);

      // Update state with success
      state = state.copyWith(
        isLoading: false,
        data: res,
        isSuccess: true,
        mfaEnabled: isMfaEnabled,
      );

      if (kDebugMode) {
        debugPrint("✅ Registration successful - MFA: $isMfaEnabled");
      }

      return null; // Success
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint("❌ API Exception: ${e.message}");
      }

      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return e.message;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Unexpected error in registration: $e");
      }

      const errorMsg = "An unexpected error occurred. Please try again.";
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return errorMsg;
    }
  }

  /// ✅ Helper: Parse MFA status from various formats
  bool _parseMfaStatus(dynamic mfa) {
    if (mfa == null) return false;

    if (mfa is bool) return mfa;
    if (mfa is String) {
      return mfa.toLowerCase() == 'true' || mfa == '1';
    }
    if (mfa is int) return mfa == 1;

    return false;
  }

  /// ✅ Helper: Update MFA state
  Future<void> _updateMfaState(bool enabled) async {
    try {
      await SecureStorageService.saveMfaEnabled(enabled);
      ref.read(mfaEnabledProvider.notifier).state = enabled;

      if (kDebugMode) {
        debugPrint("🔐 MFA state updated: $enabled");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⚠️ Failed to update MFA state: $e");
      }
    }
  }

  /// ✅ Helper: Save temp token for OTP verification
  Future<void> _saveTempToken(String token) async {
    try {
      await SecureStorageService.saveTempToken(token);

      if (kDebugMode) {
        debugPrint("🕓 Temp token saved for OTP verification");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⚠️ Failed to save temp token: $e");
      }
    }
  }

  /// ✅ Reset state
  void resetState() {
    state = const RegisterState();
  }

  /// ✅ Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
