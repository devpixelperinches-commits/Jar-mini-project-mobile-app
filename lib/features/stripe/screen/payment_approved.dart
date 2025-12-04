import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/controller/stripe_controller.dart';

class PaymentApprovedScreen extends ConsumerStatefulWidget {
  final String paymentId;
  final int amount;

  const PaymentApprovedScreen({
    super.key,
    required this.paymentId,
    required this.amount,
  });

  @override
  ConsumerState<PaymentApprovedScreen> createState() =>
      _PaymentApprovedScreenState();
}

class _PaymentApprovedScreenState extends ConsumerState<PaymentApprovedScreen> {
  bool _isLoading = false;

  void _setLoading(bool value) {
    if (mounted) {
      setState(() => _isLoading = value);
    }
  }

  // Format currency like £40.25
  String formatCurrency(int amountInPence) {
    return NumberFormat.currency(
      locale: 'en_GB',
      symbol: '£',
    ).format(amountInPence / 100);
  }

  // Send email receipt
  Future<void> _sendEmailReceipt(String email) async {
    final stripeController = ref.read(stripeControllerProvider);

    // ✅ Email validation
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _setLoading(true);

    try {
      final response = await stripeController.sendPaymentReceipt(
        email,
        widget.paymentId,
      );

      debugPrint("response+++++++++++ $response");

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        _setLoading(false);
        Navigator.pop(context); // close sheet
        context.go('/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email receipt sent!"),
            backgroundColor: Color(0xFF00C389),
          ),
        );
      } else {
        _setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? "Failed to send receipt."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Error sending payment receipt: $e");

      if (!mounted) return;

      _setLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Email bottom sheet
  void _showEmailBottomSheet() {
    final TextEditingController emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            bool isSending = false;

            Future<void> send() async {
              final email = emailController.text.trim();

              setSheetState(() => isSending = true);

              try {
                await _sendEmailReceipt(email);

                if (mounted) Navigator.pop(context);
              } finally {
                if (mounted) setSheetState(() => isSending = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Stack(
                children: [
                  // Bottom sheet UI
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Send Email Receipt",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Enter the customer's email address",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "customer@example.com",
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF6A0CE8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF6F6F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A0CE8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isSending ? null : send,
                            child: const Text(
                              "Send Receipt",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: isSending
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Loader overlay inside sheet
                  if (isSending)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.7),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6A0CE8),
                            strokeWidth: 4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    final formattedAmount = formatCurrency(widget.amount);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFD8FFF4), Color(0xFFB3F1E1)],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF00C389),
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Payment Approved",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "$formattedAmount successfully charged",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "Transaction ID: ${widget.paymentId}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 40),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Need a receipt?",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: _ReceiptButton(
                      icon: Icons.email_outlined,
                      label: "Email receipt",
                      onTap: _showEmailBottomSheet,
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A0CE8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => context.go('/home'),
                      child: const Text(
                        "Save & Close",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        // 🔥 LOADER OVERLAY
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6A0CE8),
                strokeWidth: 4,
              ),
            ),
          ),
      ],
    );
  }
}

// Receipt button widget
class _ReceiptButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ReceiptButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF6F6F6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF6A0CE8)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
