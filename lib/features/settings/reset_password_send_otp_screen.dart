import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/features/stripe/controller/setting_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  bool _isLoading = false;

  Future<void> _validateAndSendOtp() async {
    final controller = ref.read(settingsControllerProvider);

    setState(() {
      _isLoading = true; // show loader
    });

    try {
      final response = await controller.changePasswordSendOptCont();
      if (!mounted) return;
      if (response != null && response['status'] == 1) {
        context.push(
          '/OtpVerificationScreen',
          extra: {'token': response['token']},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['error'] ?? 'Invalid OTP'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      if (!mounted) return;
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // ✅ Correct
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Change Password", style: AppTextStyles.heading28),
                        const SizedBox(height: 16),
                        Text(
                          "For security reasons, we'll send an OTP to your registered mobile number. "
                          "If you don't have access to this number, please contact support.",
                          style: AppTextStyles.detail16,
                        ),
                        const SizedBox(height: 30),

                        // Input fields go here if needed
                        // Example:
                        // CustomInputField(...),
                        const SizedBox(height: 40),
                        CustomButton(
                          text: "Send OTP",
                          onPressed: () {
                            if (!_isLoading) _validateAndSendOtp();
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
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
