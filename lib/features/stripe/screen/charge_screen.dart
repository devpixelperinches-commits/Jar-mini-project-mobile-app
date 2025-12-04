import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/constants/colors.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/features/stripe/controller/stripe_controller.dart';
import 'package:jarpay/widgets/charge/number_pad.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/loader.dart';

class ChargeControlScreen extends ConsumerStatefulWidget {
  const ChargeControlScreen({super.key});

  @override
  ConsumerState<ChargeControlScreen> createState() =>
      _ChargeControlScreenState();
}

class _ChargeControlScreenState extends ConsumerState<ChargeControlScreen> {
  int amountInPence = 0;

  static const int minAmount = 35; // £0.35
  static const int maxAmount = 99999999; // £999,999.99 (Stripe limit)

  // -----------------------------------
  // Currency Formatting (Always £0.00)
  // -----------------------------------
  String get formattedAmount {
    double amount = amountInPence / 100;
    return "£${amount.toStringAsFixed(2)}";
  }

  // -----------------------------------
  // Number Pad Logic (SAFE VERSION)
  // -----------------------------------
  void onNumberPress(String val) {
    debugPrint('Number pressed ------------: $val');
    setState(() {
      if (val == '⌫') {
        amountInPence = amountInPence ~/ 10;
        return;
      }

      int newAmount = amountInPence;

      if (val == '00') {
        // Prevent quick overflow when user spams "00"
        if (newAmount <= maxAmount ~/ 100) {
          newAmount = newAmount * 100;
        }
      } else {
        final digit = int.tryParse(val);
        if (digit != null) {
          // Prevent large overflow
          if (newAmount <= maxAmount ~/ 10) {
            newAmount = newAmount * 10 + digit;
          }
        }
      }

      // Prevent pointless leading zeros
      if (amountInPence == 0 && val == "0") {
        return;
      }

      if (newAmount <= maxAmount) {
        amountInPence = newAmount;
      }
    });
  }

  // -----------------------------------
  // Continue Button Action
  // -----------------------------------
  Future<void> goToNextScreen() async {
    if (amountInPence < minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Amount must be at least £0.35"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final stripeController = ref.read(stripeControllerProvider);
    await stripeController.startOnboarding(
      context,
      amountInPence / 100.0,
      formattedAmount,
    );
  }

  // -----------------------------------
  // UI
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(stripeLoadingProvider);
    final bool isAmountValid = amountInPence >= minAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const CustomHeader(title: "Charge", showBackButton: false),
                const SizedBox(height: 20),

                // MAIN AMOUNT TEXT
                Text(
                  formattedAmount,
                  style: AppTextStyles.smallText11.copyWith(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Enter amount',
                  style: AppTextStyles.smallText11.copyWith(
                    color: AppColors.black,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NumberPad(onNumberPress: onNumberPress),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            // CHARGE BUTTON
                            ElevatedButton(
                              onPressed: isAmountValid ? goToNextScreen : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                backgroundColor: isAmountValid
                                    ? AppColors.green
                                    : AppColors.neutralLightGrey.withValues(
                                        alpha: 0.3,
                                      ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isAmountValid
                                    ? "Charge $formattedAmount"
                                    : "Enter amount",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isAmountValid
                                      ? Colors.black
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            if (!isAmountValid)
                              const Text(
                                "Minimum charge amount is £0.35",
                                style: TextStyle(
                                  color: AppColors.neutralLightGrey,
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          LoaderOverlay(isLoading: isLoading),
        ],
      ),
    );
  }
}
