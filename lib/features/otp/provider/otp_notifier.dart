import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/core/provider/mfa_provider.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/features/otp/controller/otp_repository.dart';

final otpNotifierProvider =
    StateNotifierProvider<OtpNotifier, AsyncValue<Map<String, dynamic>?>>((
      ref,
    ) {
      return OtpNotifier(ref, OtpRepository());
    });

class OtpNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref ref;
  final OtpRepository _repo;

  OtpNotifier(this.ref, this._repo) : super(const AsyncValue.data(null));

  Future<String?> verifyOtp(String otp, {bool isSignup = false}) async {
    state = const AsyncValue.loading();

    try {
      final tempToken = await SecureStorageService.getTempToken();

      final res = await _repo.verifyOtp({
        'otp': otp,
        'token': tempToken,
      }, isSignup: isSignup);

      if (res['accessToken'] != null) {
        await SecureStorageService.saveToken(res['accessToken']);
        await SecureStorageService.clearTempToken();
      }

      final mfaFlag = res['isMFAEnabled'] ?? res['data']?['isMFAEnabled'];
      final isMfaEnabled = (mfaFlag == true || mfaFlag == 'true');

      await SecureStorageService.saveMfaEnabled(isMfaEnabled);
      ref.read(mfaEnabledProvider.notifier).state = isMfaEnabled;

      state = AsyncValue.data(res);
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return e.toString(); // return error to controller
    }
  }

  // Future<String?> resendOtp({bool isSignup = false}) async {
  //   state = const AsyncValue.loading();
  //   try {
  //     //  API call likho (abhi comment rakha hai)
  //     // final res = await _repo.resendOtp({'isSignup': isSignup});

  //     // Success case
  //     state = const AsyncValue.data({'message': 'OTP resent successfully'});
  //     return null; // means no error
  //   } catch (e, st) {
  //     state = AsyncValue.error(e, st);
  //     return e.toString(); // return error message
  //   }
  // }
}
