import 'package:flutter/foundation.dart';
import 'package:jarpay/core/network/dio_client.dart';
import 'package:jarpay/core/network/api_endpoints.dart';

class SettingsRepository {
  /// Fetches the current user's profile information
  ///
  /// Returns user profile data from the API
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final resp = await dioClient.get(ApiEndpoints.fetchUserProfile);

      // Use debugPrint for development logging (removed in production)
      debugPrint('🌐 Fetch Profile - Status: ${resp.statusCode}');
      debugPrint('🌐 Fetch Profile - Data: ${resp.data}');

      // Validate response data
      if (resp.data == null) {
        throw Exception('Null response received from fetch user profile API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching user profile: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Updates the user's profile information
  ///
  /// [payload] - Map containing the profile fields to update
  ///
  /// Returns updated profile data from the API
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> payload,
  }) async {
    try {
      // Validate payload
      if (payload.isEmpty) {
        throw ArgumentError('Update payload cannot be empty');
      }

      debugPrint('🌐 Update Profile - Payload: $payload');

      final resp = await dioClient.put(
        ApiEndpoints.updateUserProfile,
        data: payload,
      );

      debugPrint('⬆️ Update Profile - Status: ${resp.statusCode}');
      debugPrint('⬆️ Update Profile - Response: ${resp.data}');

      // Validate response data
      if (resp.data == null) {
        throw Exception('Null response received from update user profile API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating user profile: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> changePasswordSendOtp() async {
    try {
      final resp = await dioClient.post(ApiEndpoints.changePasswordSendOtp);

      // Use debugPrint for development logging (removed in production)
      debugPrint('🌐 Fetch Profile - Status: ${resp.statusCode}');
      debugPrint('🌐 Fetch Profile - Data: ${resp.data}');

      // Validate response data
      if (resp.data == null) {
        throw Exception(
          'Null response received from change password send OTP API',
        );
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending change password OTP: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtpWhileChangePassword({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final resp = await dioClient.post(
        ApiEndpoints.changePasswordVerifyOtp,
        data: payload,
      );

      // Use debugPrint for development logging (removed in production)
      debugPrint(
        '🌐 verifyOtp While verifyOtpWhileChangePassword - Status: ${resp.statusCode}',
      );
      debugPrint(
        '🌐 verifyOtp While verifyOtpWhileChangePassword - Data: ${resp.data}',
      );

      // Validate response data
      if (resp.data == null) {
        throw Exception(
          'Null response received from change password verify OTP API',
        );
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error verifying change password OTP: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final resp = await dioClient.post(
        ApiEndpoints.changePassword,
        data: payload,
      );

      // Use debugPrint for development logging (removed in production)
      debugPrint('🌐 changePassword - Status: ${resp.statusCode}');
      debugPrint('🌐 changePassword - Data: ${resp.data}');

      // Validate response data
      if (resp.data == null) {
        throw Exception('Null response received from change password API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error changing password: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
