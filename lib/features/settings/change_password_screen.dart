import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/core/utils/validation_helper.dart';
import 'package:jarpay/features/authentication/providers/login_notifier.dart';
import 'package:jarpay/features/stripe/controller/setting_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/widgets/custom_input_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isLoading = false;
  final Map<String, String?> _errors = {};

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  void _clearError(String key) {
    setState(() => _errors[key] = null);
  }

  Future<void> _onUpdatePassword(BuildContext context) async {
    final current = _currentPassword.text.trim();
    final newPass = _newPassword.text.trim();
    final confirm = _confirmPassword.text.trim();

    setState(() => _errors.clear());

    final validationError = _validatePasswordInputs(
      currentPassword: current,
      newPassword: newPass,
      confirmPassword: confirm,
    );

    if (validationError != null) {
      return _showTopSnack(validationError, Colors.red);
    }

    try {
      final controller = ref.read(settingsControllerProvider);
      final notifier = ref.read(loginNotifierProvider.notifier);

      // 🔥 START LOADER
      setState(() => _isLoading = true);

      final response = await controller.changePassword({
        'oldPassword': current,
        'newPassword': newPass,
        'confirmPassword': confirm,
      });

      // 🔥 STOP LOADER
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response == null) {
        return _showTopSnack(
          "Something went wrong. Please try again!",
          Colors.red,
        );
      }

      if (response['status'] == 1) {
        _showTopSnack(
          "Your password has been changed for your security. Please log in again.!",
          Colors.green,
        );

        _currentPassword.clear();
        _newPassword.clear();
        _confirmPassword.clear();

        await notifier.logout();
        await SecureStorageService.clearAll();
        if (context.mounted) context.go('/login');

        return;
      }

      // ❌ Incorrect old password → Logout user
      if (response['status'] == 2) {
        _showTopSnack(
          response['error'] ?? "Old password is incorrect. Please login again.",
          Colors.red,
        );

        // 🔥 Clear loader
        setState(() => _isLoading = false);

        await notifier.logout();
        await SecureStorageService.clearAll();
        if (context.mounted) context.go('/login');

        return;
      }

      if (response['details'] != null && response['details'] is List) {
        List details = response['details'];

        final combinedMessages = details
            .map((e) => "• ${e['message']}")
            .join("\n");

        for (var err in details) {
          final field = err['field'];
          final msg = err['message'];
          _errors[field] = msg;
        }

        setState(() {});

        return _showTopSnack(combinedMessages, Colors.red);
      }

      final message = response['error'] ?? "Failed to update password";
      _showTopSnack(message, Colors.red);
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;
      _showTopSnack("Error: $e", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  String? _validatePasswordInputs({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    // Validate current password
    final currentError = ValidationHelper.validatePassword(currentPassword);
    if (currentError != null) {
      _errors["currentPassword"] = currentError;
      return currentError;
    }

    // Validate new password
    final newError = ValidationHelper.validatePassword(newPassword);
    if (newError != null) {
      _errors["newPassword"] = newError;
      return newError;
    }

    // Validate confirm password
    final confirmError = ValidationHelper.validateConfirmPassword(
      newPassword,
      confirmPassword,
    );

    if (confirmError != null) {
      _errors["confirmPassword"] = confirmError;
      return confirmError;
    }

    return null; // Everything valid
  }

  void _showTopSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomHeader(
                  title: "Change Password",
                  showBackButton: true,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Change Password",
                            style: AppTextStyles.heading28,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Please enter your current password and choose a new one.",
                            style: AppTextStyles.detail16,
                          ),
                          const SizedBox(height: 30),

                          CustomInputField(
                            label: "Current Password*",
                            hintText: "Enter current password",
                            controller: _currentPassword,
                            obscureText: !_showCurrentPassword,
                            errorText: _errors["currentPassword"],
                            onChanged: (_) => _clearError("currentPassword"),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showCurrentPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showCurrentPassword =
                                      !_showCurrentPassword,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            label: "New Password*",
                            hintText: "Enter new password",
                            controller: _newPassword,
                            obscureText: !_showNewPassword,
                            errorText: _errors["newPassword"],
                            onChanged: (_) => _clearError("newPassword"),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showNewPassword = !_showNewPassword,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            label: "Confirm Password*",
                            hintText: "Re-enter new password",
                            controller: _confirmPassword,
                            obscureText: !_showConfirmPassword,
                            errorText: _errors["confirmPassword"],
                            onChanged: (_) => _clearError("confirmPassword"),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showConfirmPassword =
                                      !_showConfirmPassword,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 40),

                          CustomButton(
                            text: "Update Password",
                            onPressed: () => _onUpdatePassword(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Loader overlay
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
