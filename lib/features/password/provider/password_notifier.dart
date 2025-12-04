import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:jarpay/core/utils/helpers/api_error_helper.dart';
import 'package:jarpay/features/password/provider/password_repository.dart';

final forgotPasswordNotifierProvider =
    StateNotifierProvider<
      ForgotPasswordNotifier,
      AsyncValue<Map<String, dynamic>?>
    >((ref) => ForgotPasswordNotifier(PasswordRepository()));

class ForgotPasswordNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final PasswordRepository _repo;
  ForgotPasswordNotifier(this._repo) : super(const AsyncValue.data(null));

  // 🔹 Send Forgot Password OTP
  Future<String?> sendForgotPasswordOtp(String contact) async {
    state = const AsyncValue.loading();

    try {
      final res = await _repo.forgotPassword({'mobileNumber': contact});

      final status = res['status'];
      if (status != 1) {
        final msg = (res['message'] ?? res['error'] ?? "Something went wrong")
            .toString();
        state = AsyncValue.error(msg, StackTrace.current);
        return msg;
      }

      state = AsyncValue.data(res);
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

  // 🔹 Verify Forgot Password OTP
  Future<String?> verifyForgotPasswordOtp({
    required String forgotToken,
    required String otp,
  }) async {
    state = const AsyncValue.loading();

    try {
      final res = await _repo.verifyForgotPasswordOtp({
        'forgotToken': forgotToken,
        'otp': otp,
      });

      debugPrint("✅ Verify Forgot Password OTP Response: $res");

      final status = res['status'];
      if (status != 1) {
        final msg = (res['message'] ?? res['error'] ?? "Something went wrong")
            .toString();
        state = AsyncValue.error(msg, StackTrace.current);
        return msg;
      }

      state = AsyncValue.data(res);
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

  // 🔹 Send Change Password OTP (for logged-in user)
  Future<String?> sendChangePasswordOtp(String contact) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.sendResetPasswordOtp({"mobileNumber": contact});

      if (res['status'] != 1) {
        final msg = (res['message'] ?? "Something went wrong").toString();
        state = AsyncValue.error(msg, StackTrace.current);
        return msg;
      }

      state = AsyncValue.data(res);
      return null;
    } catch (e, st) {
      final msg = ApiErrorHelper.extractErrorMessage(e);
      state = AsyncValue.error(msg, st);
      return msg;
    }
  }

  //
  Future<String?> verifyResetPasswordOtp({
    required String resetToken,
    required String otp,
  }) async {
    state = const AsyncValue.loading();

    try {
      final res = await _repo.verifyResetPasswordOtp({
        'resetToken': resetToken,
        'otp': otp,
      });

      debugPrint("✅ Verify reset Password OTP Response: $res");

      final status = res['status'];
      if (status != 1) {
        final msg = (res['message'] ?? res['error'] ?? "Something went wrong")
            .toString();
        state = AsyncValue.error(msg, StackTrace.current);
        return msg;
      }

      state = AsyncValue.data(res);
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

  Future<String?> forgotResetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      final res = await _repo.forgotResetPassword({
        'resetToken': resetToken,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      debugPrint("✅ Verify reset Password OTP Response: $res");

      final status = res['status'];
      if (status != 1) {
        final msg = (res['message'] ?? res['error'] ?? "Something went wrong")
            .toString();
        state = AsyncValue.error(msg, StackTrace.current);
        return msg;
      }

      state = AsyncValue.data(res);
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

  Future<Map<String, dynamic>?> resendOtp({
    required String resendOtpToken,
  }) async {
    state = const AsyncValue.loading();

    try {
      final res = await _repo.resedOtp({'resendOtpToken': resendOtpToken});
      debugPrint("✅ Resend OTP Response: $res");

      final status = res['status'];

      if (status != 1) {
        final msg = (res['message'] ?? res['error'] ?? "Something went wrong")
            .toString();

        state = AsyncValue.error(msg, StackTrace.current);
        return null; // ❌ unsuccessful → return null
      }

      // SUCCESS: update state + return full data
      state = AsyncValue.data(res);

      return res; // 🔥 send to controller + UI
    } on DioException catch (e, st) {
      final message = ApiErrorHelper.extractErrorMessage(e);
      state = AsyncValue.error(message, st);
      return null;
    } catch (e, st) {
      final message = ApiErrorHelper.extractErrorMessage(e);
      state = AsyncValue.error(message, st);
      return null;
    }
  }
}
