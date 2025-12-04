import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/features/password/provider/password_notifier.dart';

final forgotPasswordControllerProvider = Provider<ForgotPasswordController>((
  ref,
) {
  return ForgotPasswordController(ref);
});

class ForgotPasswordController {
  final Ref ref;
  ForgotPasswordController(this.ref);

  /// Sends OTP for forgot password flow
  Future<void> sendForgotPasswordOtp({
    required String contact,
    required BuildContext context,
  }) async {
    await _executePasswordOperation(
      context: context,
      operation: () => ref
          .read(forgotPasswordNotifierProvider.notifier)
          .sendForgotPasswordOtp(contact),
      successMessage: "OTP sent successfully.",
      onSuccess: (res) {
        final forgotToken = res['forgotToken'] as String? ?? '';
        return _NavigationAction(
          route: '/verifyotp',
          extra: {'source': 'forgotPassword', 'token': forgotToken},
        );
      },
    );
  }

  /// Sends OTP for reset password flow
  Future<void> sendResetPasswordOtp({
    required String contact,
    required BuildContext context,
  }) async {
    await _executePasswordOperation(
      context: context,
      operation: () => ref
          .read(forgotPasswordNotifierProvider.notifier)
          .sendChangePasswordOtp(contact),
      successMessage: "OTP sent successfully.",
      onSuccess: (res) {
        final resetToken = res['resetToken'] as String? ?? '';
        return _NavigationAction(
          route: '/verifyotp',
          extra: {'source': 'resetPassword', 'token': resetToken},
        );
      },
    );
  }

  /// Verifies OTP for forgot password flow
  Future<void> forgotPasswordVerifyOtp({
    required String otp,
    required String forgotToken,
    required BuildContext context,
  }) async {
    await _executePasswordOperation(
      context: context,
      operation: () => ref
          .read(forgotPasswordNotifierProvider.notifier)
          .verifyForgotPasswordOtp(forgotToken: forgotToken, otp: otp),
      successMessage: "OTP verified successfully.",
      onSuccess: (res) {
        final resetToken = res['resetToken'] as String? ?? '';
        return _NavigationAction(
          route: '/resetForgotPassword',
          extra: {'source': 'forgotPassword', 'token': resetToken},
        );
      },
    );
  }

  /// Verifies OTP for reset password flow
  Future<void> resetPasswordVerifyOtp({
    required String otp,
    required String resetToken,
    required BuildContext context,
  }) async {
    await _executePasswordOperation(
      context: context,
      operation: () => ref
          .read(forgotPasswordNotifierProvider.notifier)
          .verifyResetPasswordOtp(resetToken: resetToken, otp: otp),
      successMessage: "OTP verified successfully.",
      onSuccess: (res) {
        return _NavigationAction(
          route: '/reset-password',
          extra: {'forgotToken': resetToken},
        );
      },
    );
  }

  /// Resets password with new password
  Future<void> forgotResetPassword({
    required String password,
    required String confirmPassword,
    required String resetToken,
    required BuildContext context,
  }) async {
    await _executePasswordOperation(
      context: context,
      operation: () => ref
          .read(forgotPasswordNotifierProvider.notifier)
          .forgotResetPassword(
            resetToken: resetToken,
            password: password,
            confirmPassword: confirmPassword,
          ),
      successMessage: "Password reset successfully.",
      onSuccess: (res) {
        return _NavigationAction(route: '/login');
      },
    );
  }

  /// Resends OTP
  /// Resends OTP and returns updated token (if any)
  Future<Map<String, dynamic>?> resendOtp({
    required String resendOtpToken,
    required BuildContext context,
  }) async {
    try {
      // 🔥 Call API via notifier
      final response = await ref
          .read(forgotPasswordNotifierProvider.notifier)
          .resendOtp(resendOtpToken: resendOtpToken);

      // If API didn't return anything
      if (response == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to resend OTP.")));
        return null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
          content: const Text(
            "OTP resent successfully.",
            style: TextStyle(
              color: Colors.white, // ✅ Text color
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      return response; // 🔥 Return the data so UI can use the new token
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
      return null;
    }
  }

  /// Generic method to execute password operations with consistent error handling
  Future<void> _executePasswordOperation({
    required BuildContext context,
    required Future<String?> Function() operation,
    required String successMessage,
    required _NavigationAction? Function(Map<String, dynamic> res)? onSuccess,
  }) async {
    try {
      // Execute the operation
      final error = await operation();

      // Check if widget is still mounted before using context
      if (!context.mounted) return;

      // Handle operation error
      if (error != null) {
        _showErrorMessage(context, error);
        return;
      }

      // Get the state
      final state = ref.read(forgotPasswordNotifierProvider);
      final res = state.value;

      // Check if response is null
      if (res == null) {
        if (!context.mounted) return;
        _showErrorMessage(
          context,
          "Unexpected error occurred. Please try again.",
        );
        return;
      }

      // Check status and handle accordingly
      if (res['status'] == 1) {
        if (!context.mounted) return;
        _showSuccessMessage(
          context,
          res['message'] as String? ?? successMessage,
        );

        // Execute success callback if provided and get navigation action
        if (onSuccess != null) {
          final navigationAction = onSuccess(res);
          if (navigationAction != null) {
            _performNavigation(context, navigationAction);
          }
        }
      } else {
        if (!context.mounted) return;
        _showErrorMessage(
          context,
          res['message'] as String? ?? "Something went wrong.",
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorMessage(context, "An error occurred: $e");
    }
  }

  /// Helper method to show error messages
  void _showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    TopMessageHelper.showTopMessage(context, message, type: MessageType.error);
  }

  /// Helper method to show success messages
  void _showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    TopMessageHelper.showTopMessage(
      context,
      message,
      type: MessageType.success,
    );
  }

  /// Helper method to perform navigation safely
  void _performNavigation(BuildContext context, _NavigationAction action) {
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.push(action.route, extra: action.extra);
      }
    });
  }
}

/// Internal class to represent navigation actions
class _NavigationAction {
  final String route;
  final Map<String, dynamic>? extra;

  _NavigationAction({required this.route, this.extra});
}
