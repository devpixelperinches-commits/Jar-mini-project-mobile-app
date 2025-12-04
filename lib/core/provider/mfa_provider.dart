// mfa_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';

/// Riverpod state for UI reactivity
final mfaEnabledProvider = StateProvider<bool>((ref) => false);

/// On app start, load persisted MFA state into memory
final mfaInitProvider = FutureProvider<void>((ref) async {
  final stored = await SecureStorageService.getMfaEnabled();
  ref.read(mfaEnabledProvider.notifier).state = stored;
});
