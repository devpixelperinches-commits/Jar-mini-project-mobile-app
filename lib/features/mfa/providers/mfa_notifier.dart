import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/core/utils/helpers/api_error_helper.dart';
import 'package:jarpay/features/mfa/data/mfa_repository.dart';
import 'package:dio/dio.dart';

final mfaNotifierProvider =
    StateNotifierProvider<MfaNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return MfaNotifier(MfaRepository());
});

class MfaNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final MfaRepository _repo;

  MfaNotifier(this._repo) : super(const AsyncValue.data(null));

  /// Enable MFA (no body)
 Future<String?> enableMfa() async {
  state = const AsyncValue.loading();
  try {
    final res = await _repo.enableMfa();

    if (res['error'] != null) {
      final msg = res['error'].toString();
      state = AsyncValue.error(msg, StackTrace.current);
      return msg;
    }

    // Save MFA state to secure storage
    if (res['isMFAEnabled'] != null) {
      await SecureStorageService.saveMfaEnabled(res['isMFAEnabled'] == true);
    }

    state = AsyncValue.data(res);
    debugPrint("MFA Enabled Successfully: $res");
    return null;
  } on DioException catch (e, st) {
    final message = ApiErrorHelper.extractErrorMessage(e);
    state = AsyncValue.error(message, st);
    return message;
  } catch (e, st) {
    final message = ApiErrorHelper.extractErrorMessage(e);
    state = AsyncValue.error(message, st);
    return message;
  }
}


  /// Verify MFA
  Future<String?> verifyMfa(Map<String, dynamic> body) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.verifyMfa(body);

      if (res['error'] != null) {
        final msg = res['error'].toString();
        state = AsyncValue.error(msg, StackTrace.current);
        return msg;
      }

      state = AsyncValue.data(res);
      debugPrint("MFA Verified Successfully: $res");
      return null;
    } on DioException catch (e, st) {
      final message = ApiErrorHelper.extractErrorMessage(e);
      state = AsyncValue.error(message, st);
      return message;
    } catch (e, st) {
      final message = ApiErrorHelper.extractErrorMessage(e);
      state = AsyncValue.error(message, st);
      return message;
    }
  }

  /// Disable MFA 
 Future<String?> disableMfa() async {
  state = const AsyncValue.loading();
  try {
    final res = await _repo.disableMfa();

    if (res['error'] != null) {
      final msg = res['error'].toString();
      state = AsyncValue.error(msg, StackTrace.current);
      return msg;
    }

    // ✅ Clear MFA secure flag locally
    await SecureStorageService.saveMfaEnabled(false);

    state = AsyncValue.data(res);
    debugPrint("MFA Disabled Successfully: $res");
    return null;
  } on DioException catch (e, st) {
    final message = ApiErrorHelper.extractErrorMessage(e);
    state = AsyncValue.error(message, st);
    return message;
  } catch (e, st) {
    final message = ApiErrorHelper.extractErrorMessage(e);
    state = AsyncValue.error(message, st);
    return message;
  }
}
}
