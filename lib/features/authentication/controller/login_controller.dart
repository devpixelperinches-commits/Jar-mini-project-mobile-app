import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/features/authentication/providers/login_notifier.dart';

final loginControllerProvider = Provider<LoginController>((ref) {
  return LoginController(ref);
});

class LoginController {
  final Ref ref;
  LoginController(this.ref);

  /// Main login function
  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final notifier = ref.read(loginNotifierProvider.notifier);

    // 1️⃣ Call login API
    final error = await notifier.login(email, password);
    if (!context.mounted) return;

    // 2️⃣ Handle error
    if (error != null) {
      TopMessageHelper.showTopMessage(context, error, type: MessageType.error);
      return;
    }

    // Get current state
    final state = ref.read(loginNotifierProvider);

    // Handle success case
    if (state.isSuccess && state.data != null) {
      _handleSuccessfulLogin(
        context: context,
        responseData: state.data!,
        requiresMfa: state.requiresMfa,
      );
    } else {
      // Fallback error message
      TopMessageHelper.showTopMessage(
        context,
        'Unexpected error occurred. Please try again.',
        type: MessageType.error,
      );
    }
  }

  /// ✅ Handle successful login with proper flow detection
  void _handleSuccessfulLogin({
    required BuildContext context,
    required Map<String, dynamic> responseData,
    required bool requiresMfa,
  }) {
    final message = responseData['message']?.toString().toLowerCase() ?? '';

    // Check if MFA is required
    if (requiresMfa || message.contains('mfa')) {
      _handleMfaFlow(context, responseData);
      return;
    }

    // Check if OTP verification is required
    final hasToken =
        responseData['data']?['token'] != null || responseData['token'] != null;

    if (hasToken || _isOtpBasedFlow(message)) {
      _handleOtpFlow(context, responseData);
      return;
    }
  }

  /// ✅ Handle MFA verification flow
  void _handleMfaFlow(BuildContext context, Map<String, dynamic> responseData) {
    TopMessageHelper.showTopMessage(
      context,
      "Please verify your MFA code.",
      type: MessageType.warning,
    );

    _delayedNavigate(
      context,
      '/mfaVerify',
      extra: {'source': 'login', 'data': responseData},
    );
  }

  /// ✅ Check if this is an OTP-based flow
  bool _isOtpBasedFlow(String message) {
    final otpKeywords = [
      'otp sent',
      'otp has been sent',
      'verification code',
      'verify your account',
    ];

    return otpKeywords.any((keyword) => message.contains(keyword));
  }

  /// ✅ Handle OTP verification flow
  void _handleOtpFlow(BuildContext context, Map<String, dynamic> responseData) {
    final customMessage =
        responseData['message']?.toString() ??
        "OTP has been sent to your registered mobile number.";

    TopMessageHelper.showTopMessage(
      context,
      customMessage,
      type: MessageType.success,
    );

    _delayedNavigate(
      context,
      '/otp',
      extra: {'source': 'login', 'data': responseData},
    );
  }

  /// Helper function to delay navigation safely
  Future<void> _delayedNavigate(
    BuildContext context,
    String route, {
    Map<String, dynamic>? extra,
    Duration delay = const Duration(seconds: 1),
  }) async {
    await Future.delayed(delay);
    if (context.mounted) {
      context.push(route, extra: extra);
    }
  }
}
