import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/provider/setting_notifier.dart';

/// Provider for managing loading state during stripe operations
final stripeLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for SettingsController instance
final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref),
);

class SettingsController {
  final Ref ref;

  SettingsController(this.ref);

  /// Fetches user profile data
  ///
  /// Returns user profile data if successful, null if error occurs
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final result = await ref
          .read(settingsNotifierProvider.notifier)
          .fetchUserProfile();

      return result;
    } catch (e) {
      // Consider logging the error for debugging
      // debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Updates user profile with provided data
  ///
  /// [payload] - The data to update the profile with
  /// Returns updated profile data if successful, null if error occurs
  Future<Map<String, dynamic>?> updateUserProfile(
    Map<String, dynamic> payload,
  ) async {
    try {
      final result = await ref
          .read(settingsNotifierProvider.notifier)
          .updateUserProfile(payload: payload);

      return result;
    } catch (e) {
      // Consider logging the error for debugging
      // debugPrint('Error updating user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> changePasswordSendOptCont() async {
    try {
      final result = await ref
          .read(settingsNotifierProvider.notifier)
          .changePasswordSendOtpProvider();

      return result;
    } catch (e) {
      // Consider logging the error for debugging
      // debugPrint('Error sending change password OTP: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOtpWhileChangePassword(
    Map<String, dynamic> payload,
  ) async {
    try {
      final result = await ref
          .read(settingsNotifierProvider.notifier)
          .verifyOtpWhileChangePassword(payload: payload);

      return result;
    } catch (e) {
      // Consider logging the error for debugging
      // debugPrint('Error sending change password OTP: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> changePassword(
    Map<String, dynamic> payload,
  ) async {
    try {
      final result = await ref
          .read(settingsNotifierProvider.notifier)
          .changePassword(payload: payload);

      return result;
    } catch (e) {
      // Consider logging the error for debugging
      // debugPrint('Error sending change password OTP: $e');
      return null;
    }
  }
}
