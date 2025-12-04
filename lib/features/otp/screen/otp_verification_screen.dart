import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/features/otp/controller/otp-controller.dart';
import 'package:jarpay/features/password/controller/password_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/features/otp/provider/otp_notifier.dart';
import 'package:jarpay/widgets/custom_otp_field.dart';

class OtpVerification extends ConsumerStatefulWidget {
  const OtpVerification({super.key});

  @override
  ConsumerState<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends ConsumerState<OtpVerification> {
  String otpCode = "";
  String? otpError;
  late String source;
  late String _resendToken;

  // 🔥 Countdown variables
  int _secondsRemaining = 60;
  bool _isTimerRunning = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map && extra['source'] != null) {
        setState(() => source = extra['source']);
      } else {
        setState(() => source = 'login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Future<void> _verifyOtp() async {
    final otpController = ref.read(otpControllerProvider);
    await otpController.verifyOtp(
      otpCode: otpCode,
      source: source,
      context: context,
    );
  }

  Future<void> _onResendOtp() async {
    if (_isTimerRunning) return; // ⛔ Block if countdown running

    // 1️⃣ Read the saved temp token
    final resendToken = await SecureStorageService.getTempToken();

    if (resendToken == null || resendToken.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Resend token not found.")));
      return;
    }

    final controller = ref.read(forgotPasswordControllerProvider);
    final response = await controller.resendOtp(
      resendOtpToken: resendToken,
      context: context,
    );
    debugPrint('Resend OTP response ----------------: $response');

    if (response != null && response['token'] != null) {
      // Update token for future resends
      setState(() => _resendToken = response['token']);
    }

    // Start 1 minute timer
    _startOtpTimer();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpNotifierProvider);

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
                    const Text(
                      "One time password has been sent to your number",
                      style: AppTextStyles.detail16,
                    ),
                    const SizedBox(height: 40),

                    /// OTP Input Field
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

                    otpState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Verify OTP",
                            onPressed: _verifyOtp,
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
