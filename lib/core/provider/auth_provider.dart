import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return await SecureStorageService.getToken();
});

final userIdProvider = StateProvider<String?>((ref) => null);

/// Holds an access token issued prior to MFA verification. The token
/// is only persisted once the MFA challenge succeeds.
final pendingAccessTokenProvider = StateProvider<String?>((ref) => null);
