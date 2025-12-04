import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/utils/validation_helper.dart';
import 'package:jarpay/features/password/controller/password_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_input_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _number = TextEditingController();
  final Map<String, String> _errors = {};
  bool _isLoading = false; // add loading state

  void _clearError(String key) {
    setState(() => _errors.remove(key));
  }

  Future<void> _validateAndSendOtp() async {
    setState(() {
      _errors.clear();
      final validationError = ValidationHelper.validateContact(
        _number.text.trim(),
      );
      if (validationError != null) {
        _errors["number"] = validationError;
      }
    });

    if (_errors.isNotEmpty) return;

    setState(() => _isLoading = true); // start loading

    try {
      final controller = ref.read(forgotPasswordControllerProvider);
      await controller.sendForgotPasswordOtp(
        contact: _number.text.trim(),
        context: context,
      );
    } finally {
      setState(() => _isLoading = false); // stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "Forgot Password"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Forgot Password",
                      style: AppTextStyles.heading28,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Don't worry! It happens. Please enter your registered mobile number.",
                      style: AppTextStyles.detail16,
                    ),
                    const SizedBox(height: 30),
                    CustomInputField(
                      label: "Mobile Number*",
                      hintText: "Enter your number",
                      controller: _number,
                      errorText: _errors["number"],
                      onChanged: (_) => _clearError("number"),
                    ),
                    const SizedBox(height: 40),

                    // Show loading indicator or button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Send OTP",
                            onPressed: _validateAndSendOtp,
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
