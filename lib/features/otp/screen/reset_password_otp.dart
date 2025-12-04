import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/features/password/controller/password_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_otp_field.dart';

class ResetOtpVerification extends ConsumerStatefulWidget {
  final String source; // forgotPassword | resetPassword
  final String token;

  const ResetOtpVerification({
    super.key,
    required this.source,
    required this.token,
  });

  @override
  ConsumerState<ResetOtpVerification> createState() =>
      _ResetOtpVerificationState();
}

class _ResetOtpVerificationState extends ConsumerState<ResetOtpVerification> {
  String otpCode = "";
  String? otpError;
  bool isLoading = false;
  late String _resendToken;

  // 🔥 Countdown variables
  int _secondsRemaining = 60;
  bool _isTimerRunning = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resendToken = widget.token;
    _startOtpTimer();
  }

  // 🔥 Start OTP Countdown Timer
  void _startOtpTimer() {
    _secondsRemaining = 60;
    _isTimerRunning = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        if (mounted) {
          setState(() => _isTimerRunning = false);
        }
      } else {
        if (mounted) {
          setState(() => _secondsRemaining--);
        }
      }
    });
  }

  Future<void> _validateAndProceed() async {
    otpError = null;
    if (otpCode.isEmpty) {
      setState(() => otpError = "Please enter OTP");
      return;
    } else if (otpCode.length < 6) {
      setState(() => otpError = "OTP must be 6 digits");
      return;
    }

    setState(() => isLoading = true);
    final controller = ref.read(forgotPasswordControllerProvider);

    if (widget.source == "forgotPassword") {
      await controller.forgotPasswordVerifyOtp(
        otp: otpCode,
        forgotToken: widget.token,
        context: context,
      );
    } else {
      await controller.resetPasswordVerifyOtp(
        otp: otpCode,
        resetToken: widget.token,
        context: context,
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _onResendOtp() async {
    if (_isTimerRunning) return; // ⛔ Block if countdown running

    final controller = ref.read(forgotPasswordControllerProvider);
    final response = await controller.resendOtp(
      resendOtpToken: _resendToken,
      context: context,
    );
    debugPrint('Resend OTP response ----------------: $response');
    if (response != null && response['token'] != null) {
      // Update token for future resends
      setState(() => _resendToken = response['token']);
    }

    _startOtpTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "OTP Verification",
                      style: AppTextStyles.heading28,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.source == "forgotPassword"
                          ? "A one-time password has been sent to your registered contact."
                          : "Please verify the OTP sent to reset your password.",
                      style: AppTextStyles.detail16,
                    ),
                    const SizedBox(height: 40),
                    CustomOtpField(
                      length: 6,
                      onChanged: (otp) => otpCode = otp,
                    ),
                    if (otpError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        otpError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 40),
                    CustomButton(
                      text: isLoading ? "Verifying..." : "Verify OTP",
                      onPressed: _validateAndProceed,
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: _isTimerRunning
                          ? Text(
                              "Resend OTP in $_secondsRemaining sec",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            )
                          : TextButton(
                              onPressed: _onResendOtp,
                              child: const Text(
                                "Resend OTP",
                                style: AppTextStyles.detail16,
                              ),
                            ),
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
