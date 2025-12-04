import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/features/password/controller/password_controller.dart';
import 'package:jarpay/features/stripe/controller/setting_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_otp_field.dart';

class OtpVerificationPasswordScreen extends ConsumerStatefulWidget {
  const OtpVerificationPasswordScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<OtpVerificationPasswordScreen> createState() =>
      _OtpVerificationPasswordScreenState();
}

class _OtpVerificationPasswordScreenState
    extends ConsumerState<OtpVerificationPasswordScreen> {
  String otpCode = "";
  String? otpError;
  bool _isLoading = false;
  late String source;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map && extra['source'] != null) {
        setState(() => source = extra['source']);
      } else {
        setState(() => source = 'login');
      }
    });
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
    if (_isLoading) return;

    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid 6-digit OTP"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          elevation: 10,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(settingsControllerProvider);

      final response = await controller.verifyOtpWhileChangePassword({
        'otp': otpCode,
      });

      if (!mounted) return;

      if (response != null && response['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP verified successfully"),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 20, left: 16, right: 16),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) context.push('/change-password');
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
      debugPrint("OTP verify error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onResendOtp() async {
    if (_isTimerRunning) return; // ⛔ Block if countdown running

    if (_resendToken.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Resend token not found.")));
      return;
    }

    final controller = ref.read(forgotPasswordControllerProvider);
    final response = await controller.resendOtp(
      resendOtpToken: _resendToken,
      context: context,
    );

    // 🔥 If API returns a new resend token, update it
    if (response != null && response['token'] != null) {
      setState(() => _resendToken = response['token']);
    }

    _startOtpTimer(); // 🔥 Restart countdown after resend
  }

  @override
  void dispose() {
    _timer?.cancel(); // 🔥 Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(forgotPasswordControllerProvider);

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

                    _isLoading
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
