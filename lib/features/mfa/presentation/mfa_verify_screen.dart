import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/mfa/controller/mfa_controller.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_otp_field.dart'; 

class MfaVerifyScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> params;
  const MfaVerifyScreen({super.key, required this.params});

  @override
  ConsumerState<MfaVerifyScreen> createState() => _MfaVerifyScreenState();
}

class _MfaVerifyScreenState extends ConsumerState<MfaVerifyScreen> {
  String _otp = '';
  bool _isLoading = false;
Future<void> _verify() async {
  if (_otp.length != 6) {
    TopMessageHelper.showTopMessage(
      context,
      "Please enter the 6-digit code.",
      type: MessageType.warning,
    );
    return;
  }

  setState(() => _isLoading = true);

  final controller = ref.read(mfaControllerProvider);

  await controller.verifyMfa(
    context: context,
    otp: _otp, 
  );

  if (!mounted) return;
  setState(() => _isLoading = false);
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "Verify MFA"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Enter the 6-digit code from your Authenticator app.",
                      style: AppTextStyles.detail16,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // 🔢 Custom OTP Field
                    CustomOtpField(
                      length: 6,
                      onChanged: (value) => _otp = value,
                      onCompleted: (value) {
                        _otp = value;
                      },
                    ),

                    const SizedBox(height: 40),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            text: "Verify & Continue",
                            onPressed: _verify,
                          ),
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
