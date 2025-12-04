import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/features/stripe/helpers/stripe_secure_helper.dart';
import 'package:jarpay/features/stripe/provider/stripe_notifier.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/widgets/charge/payment_modal.dart';
import 'package:jarpay/widgets/popup/stripte_onbording_popup.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Provider for managing loading state during stripe operations
final stripeLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for StripeController instance
final stripeControllerProvider = Provider<StripeController>(
  (ref) => StripeController(ref),
);

class StripeController {
  final Ref ref;

  StripeController(this.ref);

  /// Starts the Stripe onboarding flow and handles payment modal
  ///
  /// [context] - BuildContext for UI operations
  /// [amount] - Payment amount to be charged
  Future<void> startOnboarding(
    BuildContext context,
    double amount,
    String formattedAmount,
  ) async {
    final notifier = ref.read(stripeNotifierProvider.notifier);
    final loader = ref.read(stripeLoadingProvider.notifier);

    loader.state = true;

    try {
      final res = await notifier.createConnectedAccount();

      if (!context.mounted) return;

      debugPrint('✅ startOnboarding response: $res');

      if (res == null) {
        _showErrorMessage(context, "Failed to create connected account");
        return;
      }

      final bool success = res['success'] as bool? ?? false;
      final data = res['data'] as Map<String, dynamic>?;

      if (!success || data == null) {
        _showErrorMessage(context, "Invalid response from server");
        return;
      }

      final connectedAccountId = data['connectedAccountId'] as String?;
      final status = data['status'] as String?;
      final onboardingUrl = data['url'] as String?;

      // Save connected account ID securely
      if (connectedAccountId != null && connectedAccountId.isNotEmpty) {
        await secureWrite('stripeAccountId', connectedAccountId);
      }

      if (!context.mounted) return;

      // Check if onboarding is already completed
      if (status != null && status.toLowerCase() == 'completed') {
        _showPaymentOptions(context, amount, formattedAmount);
        return;
      }

      // Show onboarding bottom sheet if URL is available
      if (onboardingUrl != null && onboardingUrl.isNotEmpty) {
        _showOnboardingSheet(context, onboardingUrl);
      } else {
        _showErrorMessage(context, "Onboarding URL not available");
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in startOnboarding: $e\n$stackTrace');
      if (!context.mounted) return;
      _showErrorMessage(context, "Error during onboarding: $e");
    } finally {
      loader.state = false;
    }
  }

  /// Creates a Stripe location for the connected account
  ///
  /// [context] - BuildContext for UI operations
  /// [address] - Business address for the location
  Future<void> addStripeLocation(
    BuildContext context, {
    required String address,
  }) async {
    // Validate address
    if (address.trim().isEmpty) {
      _showErrorMessage(context, "Address cannot be empty");
      return;
    }

    final loader = ref.read(stripeLoadingProvider.notifier);
    loader.state = true;

    try {
      final notifier = ref.read(stripeNotifierProvider.notifier);
      final res = await notifier.createStripeLocation(address: address);

      if (!context.mounted) return;

      if (res == null || !(res['success'] as bool? ?? false)) {
        final message =
            res?['message'] as String? ?? "Failed to create location";
        _showErrorMessage(context, message);
        return;
      }

      _showSuccessMessage(context, "Location created successfully");
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating location: $e\n$stackTrace');
      if (!context.mounted) return;
      _showErrorMessage(context, "Error creating location: $e");
    } finally {
      loader.state = false;
    }
  }

  /// Creates a payment intent for card payments
  ///
  /// [amount] - Amount in smallest currency unit (e.g., pence for GBP)
  /// [currency] - Three-letter ISO currency code (e.g., 'gbp', 'usd')
  /// [applicationFeeAmount] - Optional fee amount for platform
  ///
  /// Returns payment intent data if successful, null otherwise
  Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String currency,
    int? applicationFeeAmount,
  }) async {
    try {
      // Validate inputs
      if (amount <= 0) {
        debugPrint('❌ Invalid amount: $amount');
        return null;
      }
      if (currency.isEmpty || currency.length != 3) {
        debugPrint('❌ Invalid currency code: $currency');
        return null;
      }
      if (applicationFeeAmount != null && applicationFeeAmount < 0) {
        debugPrint('❌ Invalid application fee: $applicationFeeAmount');
        return null;
      }

      return await ref
          .read(stripeNotifierProvider.notifier)
          .createPaymentIntent(
            amount: amount,
            currency: currency.toLowerCase(),
            applicationFeeAmount: applicationFeeAmount,
          );
    } catch (e) {
      debugPrint('❌ Error creating payment intent: $e');
      return null;
    }
  }

  /// Captures a previously authorized payment intent
  ///
  /// [id] - Payment intent ID to capture
  ///
  /// Returns captured payment data if successful, null otherwise
  Future<Map<String, dynamic>?> capturePaymentIntent({
    required String id,
    required String? last4,
    required String? brand,
  }) async {
    try {
      if (id.isEmpty) {
        debugPrint('❌ Payment intent ID cannot be empty');
        return null;
      }

      return await ref
          .read(stripeNotifierProvider.notifier)
          .capturePayment(id: id, last4: last4, brand: brand);
    } catch (e) {
      debugPrint('❌ Error capturing payment: $e');
      return null;
    }
  }

  /// Creates a bank payment (ACH/Direct Debit)
  ///
  /// [amount] - Amount in smallest currency unit
  /// [currency] - Three-letter ISO currency code
  ///
  /// Returns bank payment data if successful, null otherwise
  Future<Map<String, dynamic>?> createBankPayment({
    required int amount,
    required String currency,
  }) async {
    try {
      // Validate inputs
      if (amount <= 0) {
        debugPrint('❌ Invalid amount: $amount');
        return null;
      }
      if (currency.isEmpty || currency.length != 3) {
        debugPrint('❌ Invalid currency code: $currency');
        return null;
      }

      return await ref
          .read(stripeNotifierProvider.notifier)
          .createBankPayment(amount: amount, currency: currency.toLowerCase());
    } catch (e) {
      debugPrint('❌ Error creating bank payment: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendPaymentReceipt(
    String email,
    String transactionId,
  ) async {
    try {
      return await ref
          .read(stripeNotifierProvider.notifier)
          .sendPaymentReceipt(email: email, transactionId: transactionId);
    } catch (e) {
      debugPrint('❌ Error sending payment receipt: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchStripeBalance() async {
    try {
      return await ref
          .read(stripeNotifierProvider.notifier)
          .fetchStripeBalance();
    } catch (e) {
      debugPrint('❌ Error fetching stripe balance: $e');
      return null;
    }
  }

  /// Shows the payment options bottom sheet
  void _showPaymentOptions(
    BuildContext context,
    double amount,
    formattedAmount,
  ) {
    if (!context.mounted) return;

    final int amountInPence = amount.round();

    if (amountInPence <= 0) {
      _showErrorMessage(context, "Invalid payment amount");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PaymentOptionsModal(
        amountInPence: _toPence(formattedAmount),

        onClose: () {
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  int _toPence(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleaned) ?? 0.0;
    return (amount * 100).round();
  }

  /// Shows the onboarding completion bottom sheet
  void _showOnboardingSheet(BuildContext context, String onboardingUrl) {
    if (!context.mounted) return;

    CompleteOnboardingBottomSheet.show(
      context,
      onComplete: () async {
        if (!context.mounted) return;
        Navigator.pop(context);

        try {
          // 👇 Open inside WebView
          context.push("/onboarding-webview", extra: onboardingUrl);

          // await safeLaunchUrl(onboardingUrl);
        } catch (e) {
          if (!context.mounted) return;
          _showErrorMessage(context, "Error opening onboarding: $e");
        }
      },
    );
  }

  /// Helper method to show error messages
  void _showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    TopMessageHelper.showTopMessage(context, message, type: MessageType.error);
  }

  /// Helper method to show success messages
  void _showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    TopMessageHelper.showTopMessage(
      context,
      message,
      type: MessageType.success,
    );
  }
}
