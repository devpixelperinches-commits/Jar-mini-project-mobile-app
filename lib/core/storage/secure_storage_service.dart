import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing secure storage operations
///
/// Provides methods for storing sensitive data like auth tokens,
/// refresh tokens, user IDs, and other credentials using FlutterSecureStorage
class SecureStorageService {
  // Private constructor to prevent instantiation
  SecureStorageService._();

  /// Single secure storage instance with configuration
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ==================== Storage Keys ====================
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _tempTokenKey = 'temp_token';
  static const _forgotTokenKey = 'forgot_token';
  static const _mfaEnabledKey = 'mfa_enabled';

  // ==================== Auth Token ====================

  /// Saves the authentication token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
      debugPrint('✅ Auth token saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving auth token: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Retrieves the authentication token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      debugPrint(
        '🔍 Auth token retrieved: ${token != null ? "Found" : "Not found"}',
      );
      return token;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting auth token: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Clears the authentication token
  static Future<void> clearToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
      debugPrint('🗑️ Auth token cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing auth token: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // ==================== Refresh Token ====================

  /// Saves the refresh token
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      debugPrint('✅ Refresh token saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving refresh token: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Retrieves the refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting refresh token: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Clears the refresh token
  static Future<void> clearRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
      debugPrint('🗑️ Refresh token cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing refresh token: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // ==================== User ID ====================

  static Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      debugPrint('✅ User ID saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving user ID: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting user ID: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> clearUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
      debugPrint('🗑️ User ID cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing user ID: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // ==================== Temporary Token (OTP) ====================

  static Future<void> saveTempToken(String tempToken) async {
    try {
      await _storage.write(key: _tempTokenKey, value: tempToken);
      debugPrint('✅ Temp token saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving temp token: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String?> getTempToken() async {
    try {
      return await _storage.read(key: _tempTokenKey);
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting temp token: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> clearTempToken() async {
    try {
      await _storage.delete(key: _tempTokenKey);
      debugPrint('🗑️ Temp token cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing temp token: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // ==================== Forgot Password Token ====================

  static Future<void> saveForgotToken(String forgotToken) async {
    try {
      await _storage.write(key: _forgotTokenKey, value: forgotToken);
      debugPrint('✅ Forgot token saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving forgot token: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String?> getForgotToken() async {
    try {
      return await _storage.read(key: _forgotTokenKey);
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting forgot token: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> clearForgotToken() async {
    try {
      await _storage.delete(key: _forgotTokenKey);
      debugPrint('🗑️ Forgot token cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing forgot token: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // ==================== MFA Enabled ====================

  static Future<void> saveMfaEnabled(bool value) async {
    try {
      await _storage.write(key: _mfaEnabledKey, value: value.toString());
      debugPrint('✅ MFA enabled status saved: $value');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving MFA status: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> getMfaEnabled() async {
    try {
      final value = await _storage.read(key: _mfaEnabledKey);
      return value == 'true';
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting MFA status: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<void> clearMfaEnabled() async {
    try {
      await _storage.delete(key: _mfaEnabledKey);
      debugPrint('🗑️ MFA status cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing MFA status: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // ==================== Utility Methods ====================

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Saves user session data (access + refresh tokens + userId)
  static Future<void> saveSession({
    required String token,
    required String refreshToken,
    required String userId,
  }) async {
    try {
      await Future.wait([
        saveToken(token),
        saveRefreshToken(refreshToken),
        saveUserId(userId),
      ]);
      debugPrint('✅ User session saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving session: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Clears user session (access + refresh tokens + userId)
  static Future<void> clearSession() async {
    try {
      await Future.wait([clearToken(), clearRefreshToken(), clearUserId()]);
      debugPrint('🗑️ User session cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing session: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Clears all stored data (complete logout)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('🗑️ All secure storage data cleared');
    } catch (e, stackTrace) {
      debugPrint('❌ Error clearing all data: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Clears only the access token and refresh token
  static Future<void> clearTokens() async {
    try {
      await Future.wait([clearToken(), clearRefreshToken()]);
      debugPrint('🗑️ Tokens cleared');
    } catch (e, st) {
      debugPrint('❌ Error clearing tokens: $e\n$st');
    }
  }
}
