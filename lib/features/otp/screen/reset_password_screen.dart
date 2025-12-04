import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/features/password/controller/password_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_input_field.dart';

class ResetNewPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  final String source;
  const ResetNewPasswordScreen({
    super.key,
    required this.token,
    required this.source,
  });

  @override
  ConsumerState<ResetNewPasswordScreen> createState() =>
      _ResetNewPasswordScreenState();
}

class _ResetNewPasswordScreenState
    extends ConsumerState<ResetNewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Map<String, String?> _errors = {};
  bool _isLoading = false;

  // 🔹 Add visibility state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _clearError(String key) {
    setState(() => _errors[key] = null);
  }

  Future<void> _onResetPassword(BuildContext context) async {
    setState(() {
      _errors.clear();

      if (_passwordController.text.trim().isEmpty) {
        _errors["password"] = "Please enter password";
      } else if (_passwordController.text.trim().length < 6) {
        _errors["password"] = "Password must be at least 6 characters";
      }

      if (_confirmPasswordController.text.trim().isEmpty) {
        _errors["confirmPassword"] = "Please confirm your password";
      } else if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        _errors["confirmPassword"] = "Passwords do not match";
      }
    });

    if (_errors.isNotEmpty) return;

    setState(() => _isLoading = true);

    final controller = ref.read(forgotPasswordControllerProvider);

    await controller.forgotResetPassword(
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      resetToken: widget.token,
      context: context,
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomHeader(title: "Reset Password", showBackButton: true),
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
                      Text("Reset Password", style: AppTextStyles.heading28),
                      const SizedBox(height: 16),
                      Text(
                        "Enter and confirm your new password.",
                        style: AppTextStyles.detail16,
                      ),
                      const SizedBox(height: 30),

                      /// 🔹 New Password
                      CustomInputField(
                        label: "New Password*",
                        hintText: "Enter new password",
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        errorText: _errors["password"],
                        onChanged: (_) => _clearError("password"),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// 🔹 Confirm Password
                      CustomInputField(
                        label: "Confirm Password*",
                        hintText: "Re-enter new password",
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        errorText: _errors["confirmPassword"],
                        onChanged: (_) => _clearError("confirmPassword"),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// 🔹 Button
                      CustomButton(
                        text: _isLoading ? "Please wait..." : "Reset Password",
                        onPressed: () => _onResetPassword(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
