import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/features/otp/provider/otp_notifier.dart';

final otpControllerProvider = Provider<OtpController>((ref) {
  return OtpController(ref);
});

class OtpController {
  final Ref ref;
  OtpController(this.ref);

  Future<void> verifyOtp({
    required String otpCode,
    required String source,
    required BuildContext context,
  }) async {
    if (otpCode.isEmpty) {
      TopMessageHelper.showTopMessage(
        context,
        "Please enter the OTP",
        type: MessageType.error,
      );
      return;
    }

    final notifier = ref.read(otpNotifierProvider.notifier);
    final error = await notifier.verifyOtp(
      otpCode,
      isSignup: source == 'signup',
    );

    if (error != null) {
      TopMessageHelper.showTopMessage(context, error, type: MessageType.error);
      return;
    }

    final state = ref.read(otpNotifierProvider);
    final res = state.value;
    if (res == null) return;

    final message = res['message']?.toString() ?? '';
    final status = res['status'];
    final apiError = res['error']?.toString() ?? '';

    if (apiError.isNotEmpty) {
      TopMessageHelper.showTopMessage(
        context,
        apiError,
        type: MessageType.error,
      );
      return;
    }

    if (status == 1) {
      final successMsg = source == 'signup'
          ? "Account activated!"
          : "Login Successful";

      TopMessageHelper.showTopMessage(
        context,
        successMsg,
        type: MessageType.success,
      );

      Future.delayed(const Duration(seconds: 1), () {
        context.push('/home');
      });
      return;
    }

    // fallback
    if (message.isNotEmpty) {
      TopMessageHelper.showTopMessage(
        context,
        message,
        type: MessageType.success,
      );
    }
  }

  // Future<void> resendOtp({
  //   required BuildContext context,
  //   required bool isSignup,
  // }) async {
  //   final notifier = ref.read(otpNotifierProvider.notifier);
  //   final error = await notifier.resendOtp(isSignup: isSignup);

  //   if (error != null) {
  //     TopMessageHelper.showTopMessage(context, error, type: MessageType.error);
  //     return;
  //   }

  //   TopMessageHelper.showTopMessage(
  //     context,
  //     "OTP resent successfully.",
  //     type: MessageType.success,
  //   );
  // }



}
