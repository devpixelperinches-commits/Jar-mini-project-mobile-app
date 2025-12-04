import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/helpers/stripe_terminal_helper.dart';
import 'package:jarpay/features/stripe/controller/stripe_controller.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';
import 'package:jarpay/features/stripe/screen/payment_approved.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

/// Payment step enum for better state management
enum PaymentStep {
  creating(1, 'Creating payment intent...', 'Setting up your payment'),
  collecting(
    2,
    'Collecting payment method...',
    'Please tap or insert your card',
  ),
  confirming(3, 'Confirming payment...', 'Processing your payment'),
  capturing(4, 'Capturing payment...', 'Finalizing transaction'),
  completed(4, 'Payment successful', 'Your payment was processed successfully');

  final int stepNumber;
  final String title;
  final String message;

  const PaymentStep(this.stepNumber, this.title, this.message);
}

/// Payment state model
class PaymentState {
  final PaymentStep step;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final Color statusColor;

  const PaymentState({
    required this.step,
    this.isLoading = true,
    this.isSuccess = false,
    this.errorMessage,
    Color? statusColor,
  }) : statusColor = statusColor ?? const Color(0xFFB9F7E8);

  PaymentState copyWith({
    PaymentStep? step,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    Color? statusColor,
  }) {
    return PaymentState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

/// Enhanced Payment Setup Screen
class PaymentSetupScreen extends ConsumerStatefulWidget {
  final String serialNumber;
  final int amountInPence;

  const PaymentSetupScreen({
    super.key,
    required this.serialNumber,
    required this.amountInPence,
  });

  @override
  ConsumerState<PaymentSetupScreen> createState() => _PaymentSetupScreenState();
}

class _PaymentSetupScreenState extends ConsumerState<PaymentSetupScreen> {
  PaymentState _paymentState = const PaymentState(step: PaymentStep.creating);

  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    // 🔍 Debug: Log the amount received
    debugPrint(
      "💳 PaymentSetupScreen received amount: ${widget.amountInPence} pence (£${(widget.amountInPence / 100).toStringAsFixed(2)})",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePaymentIntent();
    });
  }

  /// ✅ Main payment initialization flow
  Future<void> _initializePaymentIntent() async {
    if (_isCancelled) return;

    try {
      // 🔍 Debug: Log the amount being processed
      debugPrint(
        "💰 Processing payment for amount: ${widget.amountInPence} pence (£${(widget.amountInPence / 100).toStringAsFixed(2)})",
      );

      // Validate reader connection first
      if (!StripeTerminalHelper.isReaderConnected()) {
        _handleError('No reader connected. Please connect a reader first.');
        return;
      }

      final stripeController = ref.read(stripeControllerProvider);
      final terminal = StripeTerminalHelper.instance;

      // Step 1: Create PaymentIntent
      await _updateState(PaymentStep.creating);

      debugPrint(
        "🔵 Calling createPaymentIntent API with amount: ${widget.amountInPence}",
      );

      final createResponse = await stripeController.createPaymentIntent(
        amount: widget.amountInPence,
        currency: 'GBP',
      );

      if (_isCancelled) return;

      if (!_validateResponse(createResponse, 'clientSecret')) {
        _handleError('Failed to create payment intent.');
        return;
      }

      final clientSecret = createResponse!['data']['clientSecret'] as String;
      debugPrint(
        "✅ Client Secret obtained: ${clientSecret.substring(0, 20)}...",
      );

      // Step 2: Collect payment method
      await _updateState(PaymentStep.collecting);

      debugPrint("🔵 Retrieving payment intent from Stripe Terminal...");

      final paymentIntent = await terminal.retrievePaymentIntent(clientSecret);

      if (_isCancelled) return;

      debugPrint("🔵 Collecting payment method from card reader...");
      debugPrint(
        "📟 Card reader will display: £${(widget.amountInPence / 100).toStringAsFixed(2)}",
      );

      final collectedPaymentIntent = await terminal.collectPaymentMethod(
        paymentIntent,
      );

      debugPrint("✅ Payment method collected");

      // Step 3: Confirm payment
      await _updateState(PaymentStep.confirming);

      if (_isCancelled) return;

      debugPrint("🔵 Confirming payment intent...");

      final processedPaymentIntent = await terminal.confirmPaymentIntent(
        collectedPaymentIntent,
      );

      final paymentIntentId = processedPaymentIntent.id;
      debugPrint("✅ Payment confirmed - ID: $paymentIntentId");
      debugPrint(
        "✅confirmPaymentIntent processedPaymentIntentD: $processedPaymentIntent",
      );

      // Step 4: Capture payment
      await _updateState(PaymentStep.capturing);

      if (_isCancelled) return;

      debugPrint("🔵 Capturing payment intent...");

      final charge = processedPaymentIntent.charges.isNotEmpty
          ? processedPaymentIntent.charges.first
          : null;

      final cardPresent = charge!.paymentMethodDetails?.cardPresent;
      final last4 = cardPresent?.last4;
      final brand = cardPresent?.brand?.name;
      final captureResponse = await stripeController.capturePaymentIntent(
        id: paymentIntentId,
        last4: last4,
        brand: brand,
      );

      debugPrint("✅ captureResponse -----------: $captureResponse");

      if (!_validateResponse(captureResponse, 'id')) {
        _handleError('Failed to capture payment.');
        return;
      }

      final captureData = captureResponse!['data'] as Map<String, dynamic>;
      final paymentId = captureData['id'] as String;
      final amount = captureData['amount'] as int;

      debugPrint(
        "✅ Payment captured - ID: $paymentId, Amount: $amount pence (£${(amount / 100).toStringAsFixed(2)})",
      );

      // Step 5: Show success and navigate
      await _updateState(
        PaymentStep.completed,
        isSuccess: true,
        statusColor: const Color(0xFFB6F5C6),
      );

      if (_isCancelled || !mounted) return;

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      debugPrint(
        "🔄 Navigating to PaymentApprovedScreen with amount: $amount pence",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentApprovedScreen(paymentId: paymentId, amount: amount),
        ),
      );
    } on TerminalException catch (e) {
      debugPrint("❌ Terminal Exception: ${e.code} - ${e.message}");
      _handleError(_getTerminalErrorMessage(e));
    } catch (e, st) {
      debugPrint("❌ Payment error: $e\n$st");
      _handleError('Payment failed: ${e.toString()}');
    }
  }

  /// ✅ Update payment state
  Future<void> _updateState(
    PaymentStep step, {
    bool isLoading = true,
    bool isSuccess = false,
    Color? statusColor,
  }) async {
    if (!mounted || _isCancelled) return;

    setState(() {
      _paymentState = _paymentState.copyWith(
        step: step,
        isLoading: isLoading,
        isSuccess: isSuccess,
        statusColor: statusColor,
      );
    });

    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// ✅ Validate API response
  bool _validateResponse(Map<String, dynamic>? response, String requiredField) {
    if (response == null) {
      debugPrint("❌ Response is null");
      return false;
    }

    if (response['data'] == null) {
      debugPrint("❌ Response data is null");
      return false;
    }

    if (response['data'][requiredField] == null) {
      debugPrint("❌ Required field '$requiredField' is missing");
      return false;
    }

    return true;
  }

  /// ✅ Get user-friendly terminal error message
  String _getTerminalErrorMessage(TerminalException e) {
    // Note: TerminalExceptionCode is an enum, not a string
    // Check the actual error code enum values
    final code = e.code;

    if (code == TerminalExceptionCode.canceled) {
      return 'Payment was cancelled.';
    } else if (code == TerminalExceptionCode.notConnectedToReader) {
      return 'Reader is not connected. Please reconnect.';
    } else if (code.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (code.toString().toLowerCase().contains('card') &&
        code.toString().toLowerCase().contains('removed')) {
      return 'Card was removed. Please try again.';
    } else if (code.toString().toLowerCase().contains('declined')) {
      return 'Card was declined. Please try another card.';
    }

    return e.message;
  }

  /// ✅ Handle payment errors
  void _handleError(String message) {
    if (!mounted) return;

    setState(() {
      _paymentState = _paymentState.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: message,
        statusColor: const Color(0xFFFFD4D4),
      );
    });

    TopMessageHelper.showTopMessage(context, message, type: MessageType.error);
  }

  /// ✅ Cancel payment
  Future<void> _cancelPayment() async {
    if (_paymentState.isSuccess) {
      Navigator.pop(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isCancelled = true);

      // Note: mek_stripe_terminal doesn't provide a direct cancel method
      // The payment will be abandoned by not continuing the flow
      debugPrint("⚠️ Payment cancelled by user");

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// ✅ Retry payment
  Future<void> _retryPayment() async {
    setState(() {
      _isCancelled = false;
      _paymentState = const PaymentState(step: PaymentStep.creating);
    });

    await _initializePaymentIntent();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _cancelPayment();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header
                const Text(
                  'Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 50),

                // Amount display
                Text(
                  '£${(widget.amountInPence / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                // Progress bar
                _buildProgressBar(),
                const SizedBox(height: 24),

                // Status box
                _buildStatusBox(),

                const Spacer(),

                // Action buttons
                _buildActionButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Build progress bar
  Widget _buildProgressBar() {
    return Row(
      children: List.generate(3, (index) {
        final stepNumber = index + 1;
        final isActive = _paymentState.step.stepNumber >= stepNumber;

        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF5AD8C1) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }

  /// ✅ Build status box
  Widget _buildStatusBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _paymentState.statusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _paymentState.errorMessage ?? _paymentState.step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_paymentState.isSuccess)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
              if (_paymentState.errorMessage != null)
                const Icon(Icons.error, color: Colors.red, size: 24),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _paymentState.errorMessage ?? _paymentState.step.message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          if (_paymentState.isLoading) ...[
            const SizedBox(height: 12),
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ Build action buttons
  Widget _buildActionButtons() {
    if (_paymentState.errorMessage != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelPayment,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _retryPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6A0CE8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return TextButton(
      onPressed: _paymentState.isSuccess ? null : _cancelPayment,
      child: Text(
        'Cancel',
        style: TextStyle(
          color: _paymentState.isSuccess
              ? Colors.grey
              : const Color(0xFF6A0CE8),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
