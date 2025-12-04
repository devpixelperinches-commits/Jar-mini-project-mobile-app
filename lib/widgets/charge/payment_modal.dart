import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/colors.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/features/stripe/helpers/stripe_terminal_helper.dart';
import 'package:jarpay/features/stripe/screen/card_reader_screen.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:jarpay/features/stripe/screen/payment_setup.dart';

class PaymentOptionsModal extends ConsumerWidget {
  final int amountInPence;
  final VoidCallback onClose;

  const PaymentOptionsModal({
    super.key,
    required this.amountInPence,
    required this.onClose,
  });

  // --------------------------
  // Start Card Payment
  // --------------------------
  Future<void> _startCardPayment(BuildContext context, WidgetRef ref) async {
    try {
      // await StripeTerminalHelper.init();

      Reader? reader = StripeTerminalHelper.connectedReader;

      if (!context.mounted) return;

      // If reader already connected → go to payment setup
      if (reader != null) {
        debugPrint("Reader already connected: ${reader.serialNumber}");

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSetupScreen(
              serialNumber: reader.serialNumber!,
              amountInPence: amountInPence,
            ),
          ),
        );
        return;
      }

      debugPrint("No reader connected → navigating to reader selection");

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WisePosReaderScreen(
            amountInPence: amountInPence,
            onDeviceConnected: (connectedReader) {
              StripeTerminalHelper.connectedReader = connectedReader;

              debugPrint(
                "Device connected: ${connectedReader.label ?? connectedReader.serialNumber}",
              );
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("Payment error: $e");
      debugPrint(stackTrace.toString());

      if (!context.mounted) return;

      TopMessageHelper.showTopMessage(
        context,
        "Payment error: ${e.toString()}",
        type: MessageType.error,
      );
    }
  }

  // --------------------------
  // Format Amount
  // --------------------------
  String _formatAmount() {
    return "£${(amountInPence / 100).toStringAsFixed(2)}";
  }

  // --------------------------
  // Build UI
  // --------------------------
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),

            // Card Reader Option
            _buildOptionCard(
              title: "Pay with card reader\n${_formatAmount()}",
              iconPath: AppImages.card,
              onTap: () => _startCardPayment(context, ref),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --------------------------
  // Header
  // --------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Payment Methods",
          style: AppTextStyles.heading20.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset(AppImages.cross, width: 22, height: 22),
          ),
        ),
      ],
    );
  }

  // --------------------------
  // Option Card
  // --------------------------
  Widget _buildOptionCard({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.appColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconPath, height: 42, width: 42),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.step1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
