import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/core/provider/auth_provider.dart';
import 'package:jarpay/core/provider/mfa_provider.dart';
import 'package:jarpay/features/auth/data/auth_repository.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/core/utils/helpers/api_helper.dart';
import 'package:flutter/foundation.dart';

/// Login state model for better type safety
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? data;
  final bool requiresMfa;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.requiresMfa = false,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? data,
    bool? requiresMfa,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
      requiresMfa: requiresMfa ?? this.requiresMfa,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Enhanced Login Notifier Provider
final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(ref, AuthRepository()),
);

/// Enhanced Login Notifier with better error handling and type safety
class LoginNotifier extends StateNotifier<LoginState> {
  final Ref ref;
  final AuthRepository _repo;

  LoginNotifier(this.ref, this._repo) : super(const LoginState());

  /// ✅ Login with improved error handling using ApiResponse
  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final pendingTokenNotifier = ref.read(pendingAccessTokenProvider.notifier);
    pendingTokenNotifier.state = null;

    try {
      final response = await _repo.login({
        'email': email,
        'password': password,
      });

      // Handle API error response
      if (!response.success) {
        final errorMsg = response.message ?? "Login failed. Please try again.";
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return errorMsg;
      }

      final res = response.data;
      if (res == null) {
        const errorMsg = "Invalid response from server";
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return errorMsg;
      }

      // Check status field
      final status = res['status'];
      if (status != null && status != 1) {
        final msg = (res['message'] ?? res['error'] ?? "Something went wrong")
            .toString();
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return msg;
      }
      // Extract response data
      final message = res['message']?.toString().toLowerCase() ?? '';
      final accessToken = res['accessToken'] ?? res['token'];
      final tempToken = res['data']?['token'] ?? res['token'];
      final mfaRequired = res['requiresMFA'] ?? false;
      final mfaEnabled = res['data']?['mfaEnabled'] ?? res['isMFAEnabled'];

      final mfaState = mfaRequired == true || mfaEnabled == true;

      // Update MFA state
      await _updateMfaState(mfaState);

      // 🔹 Case 1: MFA Required
      if (mfaRequired == true || message.contains('mfa')) {
        if (accessToken != null) {
          pendingTokenNotifier.state = accessToken;
        }

        state = state.copyWith(
          isLoading: false,
          data: res,
          requiresMfa: true,
          isSuccess: true,
        );
        return null; // MFA screen will handle next step
      }

      // 🔹 Case 2: Normal Login (OTP-based)
      if (tempToken != null) {
        await _saveTempToken(tempToken);
      }

      final pendingToken = ref.read(pendingAccessTokenProvider);
      if (pendingToken != null && !mfaRequired) {
        await _saveAccessToken(pendingToken);
        pendingTokenNotifier.state = null;
      }

      // 🔹 Case 3: Direct login (token saved)
      if (accessToken != null && !mfaRequired) {
        await _saveAccessToken(accessToken);
        pendingTokenNotifier.state = null;
      }

      state = state.copyWith(isLoading: false, data: res, isSuccess: true);

      return null;
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint("❌ API Exception: ${e.message}");
      }

      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return e.message;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Unexpected error in login: $e");
      }

      const errorMsg = "An unexpected error occurred. Please try again.";
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return errorMsg;
    }
  }

  /// ✅ Logout with improved error handling
  Future<String?> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _repo.logout();

      if (!response.success) {
        final errorMsg = response.message ?? "Logout failed. Please try again.";
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return errorMsg;
      }

      // Clear all stored tokens and MFA state
      await _clearAllTokens();
      await _updateMfaState(false);

      state = const LoginState(); // Reset to initial state

      if (kDebugMode) {
        debugPrint("✅ Logout successful");
      }

      return null; // Success
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Logout API Exception: ${e.message}");
      }

      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return e.message;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Unexpected logout error: $e");
      }

      const errorMsg = "Logout failed. Please try again.";
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return errorMsg;
    }
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

  /// ✅ Helper: Save access token
  Future<void> _saveAccessToken(String token) async {
    try {
      await SecureStorageService.saveToken(token);

      if (kDebugMode) {
        debugPrint("✅ Access token saved");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⚠️ Failed to save access token: $e");
      }
    }
  }

  /// ✅ Helper: Save temp token
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

  /// ✅ Helper: Clear all tokens
  Future<void> _clearAllTokens() async {
    try {
      await SecureStorageService.clearToken();

      if (kDebugMode) {
        debugPrint("🗑️ All tokens cleared");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⚠️ Failed to clear tokens: $e");
      }
    }
  }

  /// ✅ Reset state (useful for navigation back from MFA screen)
  void resetState() {
    state = const LoginState();
  }

  /// ✅ Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
