// lib/features/mfa/presentation/mfa_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';

class MfaQrScreen extends StatelessWidget {
  final String qrUrl;
  final String from;
  const MfaQrScreen({super.key, required this.qrUrl, required this.from});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "MFA Setup"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text("Set Up MFA", style: AppTextStyles.heading28),
                    const SizedBox(height: 12),
                    const Text(
                      "Scan this QR code in your Authenticator app to enable 2-step verification.",
                      style: AppTextStyles.detail16,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))],
                        ),
                        child: QrImageView(
                          data: qrUrl,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: "I’ve Scanned, Continue",
                      onPressed: () => context.push('/mfaVerify', extra: {'from': 'setup'}),
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
