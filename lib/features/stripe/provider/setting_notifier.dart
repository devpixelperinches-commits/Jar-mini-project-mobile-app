import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/data/setting_repository.dart';

/// Provider for the settings repository
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

/// Provider for managing user settings state
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<Map<String, dynamic>?>>((
      ref,
    ) {
      final repository = ref.watch(settingsRepositoryProvider);
      return SettingsNotifier(repository);
    });

class SettingsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Fetches the current user's profile information
  ///
  /// Returns the user profile data if successful, null if an error occurs.
  /// Updates the state with loading, data, or error accordingly.
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final data = await _repository.fetchUserProfile();

      debugPrint('✅ User profile fetched successfully');

      // Update state with fetched data
      state = AsyncValue.data(data);
      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in fetchUserProfile notifier: $e');

      // Update state with error
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Updates the user's profile with the provided data
  ///
  /// [payload] - Map containing the profile fields to update
  ///
  /// Returns the updated profile data if successful, null if an error occurs.
  /// Updates the state with loading, data, or error accordingly.
  Future<Map<String, dynamic>?> updateUserProfile({
    required Map<String, dynamic> payload,
  }) async {
    // Validate payload
    if (payload.isEmpty) {
      debugPrint('❌ Update payload is empty');
      final error = ArgumentError('Update payload cannot be empty');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    // Set loading state
    state = const AsyncValue.loading();

    try {
      final data = await _repository.updateUserProfile(payload: payload);

      debugPrint('✅ User profile updated successfully');

      // Update state with new data
      state = AsyncValue.data(data);
      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateUserProfile notifier: $e');

      // Update state with error
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Clears the current state (useful for logout or reset scenarios)
  void clearState() {
    state = const AsyncValue.data(null);
    debugPrint('🔄 Settings state cleared');
  }

  /// Refreshes the user profile by fetching it again
  Future<void> refreshProfile() async {
    debugPrint('🔄 Refreshing user profile...');
    await fetchUserProfile();
  }

  Future<Map<String, dynamic>?> changePasswordSendOtpProvider() async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final data = await _repository.changePasswordSendOtp();

      debugPrint('✅ Change password OTP sent successfully');

      // Update state with fetched data
      state = AsyncValue.data(data);
      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in changePasswordSendOtp notifier: $e');

      // Update state with error
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOtpWhileChangePassword({
    required Map<String, dynamic> payload,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final data = await _repository.verifyOtpWhileChangePassword(
        payload: payload,
      );

      debugPrint('✅ Verify OTP successful');

      // Update state with fetched data
      state = AsyncValue.data(data);
      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in verifyOtpWhileChangePassword notifier: $e');

      // Update state with error
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<Map<String, dynamic>?> changePassword({
    required Map<String, dynamic> payload,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final data = await _repository.changePassword(payload: payload);

      debugPrint('✅ Verify OTP successful');

      // Update state with fetched data
      state = AsyncValue.data(data);
      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in verifyOtpWhileChangePassword notifier: $e');

      // Update state with error
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }
}
