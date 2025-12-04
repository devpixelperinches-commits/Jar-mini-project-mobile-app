import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/data/striper_repository.dart';

/// Provider for the Stripe repository
final stripeRepositoryProvider = Provider<StripeRepository>(
  (ref) => StripeRepository(),
);

/// Provider for managing Stripe operations state
final stripeNotifierProvider =
    StateNotifierProvider<StripeNotifier, AsyncValue<Map<String, dynamic>?>>((
      ref,
    ) {
      final repository = ref.watch(stripeRepositoryProvider);
      return StripeNotifier(repository);
    });

class StripeNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final StripeRepository _repository;

  StripeNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Creates a Stripe connected account for the user
  ///
  /// Returns connected account data including accountId, status, and onboarding URL
  /// Returns null if an error occurs
  Future<Map<String, dynamic>?> createConnectedAccount() async {
    state = const AsyncValue.loading();

    try {
      final res = await _repository.createConnectedAccount();

      debugPrint('✅ Connected account created successfully');
      debugPrint('Response: $res');

      state = AsyncValue.data(res);
      return res;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating connected account: $e');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Creates a Stripe location for the connected account
  ///
  /// [address] - Business address for the location
  ///
  /// Returns location data if successful, null if error occurs
  Future<Map<String, dynamic>?> createStripeLocation({
    required String address,
  }) async {
    // Validate address
    if (address.trim().isEmpty) {
      debugPrint('❌ Address cannot be empty');
      final error = ArgumentError('Address is required');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final res = await _repository.createStripeLocation(address: address);

      debugPrint('✅ Stripe location created successfully');

      state = AsyncValue.data(res);
      return res;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating Stripe location: $e');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Creates a payment intent for card payments
  ///
  /// [amount] - Amount in smallest currency unit (e.g., pence for GBP)
  /// [currency] - Three-letter ISO currency code (e.g., 'gbp', 'usd')
  /// [applicationFeeAmount] - Optional platform fee amount
  ///
  /// Returns payment intent data if successful, null if error occurs
  Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String currency,
    int? applicationFeeAmount,
  }) async {
    // Validate inputs
    if (amount <= 0) {
      debugPrint('❌ Invalid amount: $amount');
      final error = ArgumentError('Amount must be greater than 0');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    if (currency.isEmpty || currency.length != 3) {
      debugPrint('❌ Invalid currency code: $currency');
      final error = ArgumentError('Currency must be a 3-letter ISO code');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    if (applicationFeeAmount != null && applicationFeeAmount < 0) {
      debugPrint('❌ Invalid application fee: $applicationFeeAmount');
      final error = ArgumentError('Application fee cannot be negative');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final res = await _repository.createPaymentIntent(
        amount: amount,
        currency: currency,
        applicationFeeAmount: applicationFeeAmount,
      );

      debugPrint('✅ Payment intent created successfully');
      debugPrint('Amount: $amount, Currency: $currency');

      state = AsyncValue.data(res);
      return res;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating payment intent: $e');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Captures a previously authorized payment intent
  ///
  /// [id] - Payment intent ID to capture
  ///
  /// Returns captured payment data if successful, null if error occurs
  Future<Map<String, dynamic>?> capturePayment({
    required String id,
    required String? last4,
    required String? brand,
  }) async {
    // Validate ID
    if (id.trim().isEmpty) {
      debugPrint('❌ Payment intent ID cannot be empty');
      final error = ArgumentError('Payment intent ID is required');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final res = await _repository.capturePayment(
        id: id,
        last4: last4,
        brand: brand,
      );

      debugPrint('✅ Payment captured successfully');
      debugPrint('Payment ID: $id');

      state = AsyncValue.data(res);
      return res;
    } catch (e, stackTrace) {
      debugPrint('❌ Error capturing payment: $e');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Creates a bank payment (ACH/Direct Debit)
  ///
  /// [amount] - Amount in smallest currency unit
  /// [currency] - Three-letter ISO currency code
  ///
  /// Returns bank payment data if successful, null if error occurs
  Future<Map<String, dynamic>?> createBankPayment({
    required int amount,
    required String currency,
  }) async {
    // Validate inputs
    if (amount <= 0) {
      debugPrint('❌ Invalid amount: $amount');
      final error = ArgumentError('Amount must be greater than 0');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    if (currency.isEmpty || currency.length != 3) {
      debugPrint('❌ Invalid currency code: $currency');
      final error = ArgumentError('Currency must be a 3-letter ISO code');
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final res = await _repository.createBankPayment(
        amount: amount,
        currency: currency,
      );

      debugPrint('✅ Bank payment created successfully');
      debugPrint('Amount: $amount, Currency: $currency');

      state = AsyncValue.data(res);
      return res;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating bank payment: $e');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendPaymentReceipt({
    required String email,
    required String transactionId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.sendPaymentReceipt(
        email: email,
        transactionId: transactionId,
      );

      debugPrint('✅ Payment receipt sent successfully');
      debugPrint('Email: $email, Transaction ID: $transactionId');

      state = AsyncValue.data(res);
      return res;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating bank payment: $e');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchStripeBalance() async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.fetchStripeBalance();

      debugPrint('✅ Stripe balance fetched successfully');

      state = AsyncValue.data(res);
      return res;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching stripe balance: $e');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Clears the current state (useful for reset scenarios)
  void clearState() {
    state = const AsyncValue.data(null);
    debugPrint('🔄 Stripe state cleared');
  }
}
