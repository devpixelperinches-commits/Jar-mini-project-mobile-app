import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/features/authentication/providers/register_notifier.dart';

final registerControllerProvider = Provider<RegisterController>((ref) {
  return RegisterController(ref);
});

class RegisterController {
  final Ref ref;
  RegisterController(this.ref);

  /// Call register API and handle success/error + navigation
  Future<void> registerUser({
    required Map<String, dynamic> userData,
    required BuildContext context,
  }) async {
    final notifier = ref.read(registerNotifierProvider.notifier);
    final error = await notifier.register(userData);

    if (error != null) {
      TopMessageHelper.showTopMessage(context, error, type: MessageType.error);
      return;
    }

    final state = ref.read(registerNotifierProvider);
    final res = state.data;

    if (res == null) return;

    final message = res['message']?.toString().toLowerCase() ?? '';
    if (message.contains('otp')) {
      TopMessageHelper.showTopMessage(
        context,
        "OTP has been sent to your mobile number.",
        type: MessageType.success,
      );

      if (context.mounted) {
        context.push('/otp', extra: {'source': 'signup'});
      }
    }
  }
}
