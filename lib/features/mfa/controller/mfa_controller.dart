// lib/features/mfa/controller/mfa_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/core/provider/auth_provider.dart';
import 'package:jarpay/core/provider/mfa_provider.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/features/mfa/providers/mfa_notifier.dart';

final mfaControllerProvider = Provider<MfaController>((ref) {
  return MfaController(ref);
});

class MfaController {
  final Ref ref;
  MfaController(this.ref);

  /// 🔹 Toggle MFA ON/OFF
  Future<void> toggleMfa({
    required bool enable,
    required BuildContext context,
  }) async {
    final notifier = ref.read(mfaNotifierProvider.notifier);
    final mfaState = ref.read(mfaEnabledProvider.notifier);

    // 🔸 Optimistic UI update
    mfaState.state = enable;

    if (enable) {
      final error = await notifier.enableMfa();
      if (error != null) {
        mfaState.state = false;
        await SecureStorageService.saveMfaEnabled(false); //  persist
        TopMessageHelper.showTopMessage(
          context,
          "Failed to enable MFA: $error",
          type: MessageType.error,
        );
        return;
      }

      final response = ref.read(mfaNotifierProvider).value;
      final qrUrl =
          (response != null && response['otpauth'] != null) ? response['otpauth'] as String : null;

      await SecureStorageService.saveMfaEnabled(true); //  persist

      if (qrUrl != null && qrUrl.isNotEmpty) {
        TopMessageHelper.showTopMessage(
          context,
          "Scan this QR code with your authenticator app.",
          type: MessageType.success,
        );

        // ✅ Navigate to QR screen
        context.push('/mfaQr', extra: {'qrUrl': qrUrl, 'from': 'settings'});
      } else {
        TopMessageHelper.showTopMessage(
          context,
          "MFA enabled but QR data missing.",
          type: MessageType.warning,
        );
      }
    } else {
      final error = await notifier.disableMfa();
      if (error != null) {
        mfaState.state = true;
        await SecureStorageService.saveMfaEnabled(true); //  persist
        TopMessageHelper.showTopMessage(
          context,
          "Failed to disable MFA: $error",
          type: MessageType.error,
        );
      } else {
        mfaState.state = false;
        await SecureStorageService.saveMfaEnabled(false); // persist
        TopMessageHelper.showTopMessage(
          context,
          "MFA disabled .",
          type: MessageType.success,
        );
      }
    }
  }

  /// 🔹 Verify MFA OTP
  Future<void> verifyMfa({
    required BuildContext context,
    required String otp,
  }) async {
    final notifier = ref.read(mfaNotifierProvider.notifier);
    final body = {'otp': otp};

    final error = await notifier.verifyMfa(body);

    if (error != null) {
      TopMessageHelper.showTopMessage(
        context,
        "Verification failed: $error",
        type: MessageType.error,
      );
      return;
    }

    // ✅ Update global state and persist
    ref.read(mfaEnabledProvider.notifier).state = true;
    await SecureStorageService.saveMfaEnabled(true);
    final pendingToken = ref.read(pendingAccessTokenProvider);
    if (pendingToken != null) {
      await SecureStorageService.saveToken(pendingToken);
      ref.read(pendingAccessTokenProvider.notifier).state = null;
    }

    // TopMessageHelper.showTopMessage(
    //   context,
    //   "MFA verified successfully.",
    //   type: MessageType.success,
    // );

    if (context.mounted) {
      context.go('/home');
    }
  }
}
