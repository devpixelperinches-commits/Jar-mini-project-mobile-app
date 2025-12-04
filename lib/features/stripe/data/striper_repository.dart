import 'package:flutter/foundation.dart';
import 'package:jarpay/core/network/dio_client.dart';
import 'package:jarpay/core/network/api_endpoints.dart';

class StripeRepository {
  /// Creates a Stripe connected account for the user
  ///
  /// Returns connected account data including accountId, status, and onboarding URL
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> createConnectedAccount() async {
    try {
      final resp = await dioClient.post(
        ApiEndpoints.createConnectedAccount,
        data: {},
      );

      debugPrint('🌐 Create Connected Account - Status: ${resp.statusCode}');
      debugPrint('🌐 Create Connected Account - Data: ${resp.data}');

      if (resp.data == null) {
        throw Exception('Null response from create connected account API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in createConnectedAccount: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Creates a Stripe location for the connected account
  ///
  /// [address] - Business address for the location
  ///
  /// Returns location data
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> createStripeLocation({
    required String address,
  }) async {
    try {
      final body = {'address': address};

      debugPrint(
        '🌐 Create Stripe Location - Endpoint: ${ApiEndpoints.createStripeLocation}',
      );
      debugPrint('📦 Create Stripe Location - Body: $body');

      final resp = await dioClient.post(
        ApiEndpoints.createStripeLocation,
        data: body,
      );

      debugPrint('✅ Create Stripe Location - Response: ${resp.data}');

      if (resp.data == null) {
        throw Exception('Null response from create stripe location API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in createStripeLocation: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Creates a payment intent for card payments
  ///
  /// [amount] - Amount in smallest currency unit (e.g., pence for GBP)
  /// [currency] - Three-letter ISO currency code (e.g., 'gbp', 'usd')
  /// [applicationFeeAmount] - Optional platform fee amount
  ///
  /// Returns payment intent data including client secret
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    int? applicationFeeAmount,
  }) async {
    try {
      final body = {
        'amount': amount,
        'currency': currency,
        'saveCard': true,
        'payment_method_types': ['card_present'],
        if (applicationFeeAmount != null)
          'applicationFeeAmount': applicationFeeAmount,
      };

      debugPrint(
        '🌐 Create Payment Intent - Endpoint: ${ApiEndpoints.createPaymentIntent}',
      );
      debugPrint('📦 Create Payment Intent - Body: $body');

      final resp = await dioClient.post(
        ApiEndpoints.createPaymentIntent,
        data: body,
      );

      debugPrint('✅ Create Payment Intent - Response: ${resp.data}');

      if (resp.data == null) {
        throw Exception('Null response from create payment intent API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in createPaymentIntent: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Captures a previously authorized payment intent
  ///
  /// [id] - Payment intent ID to capture
  ///
  /// Returns captured payment data
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> capturePayment({
    required String id,
    required String? last4,
    required String? brand,
  }) async {
    try {
      final body = {'paymentIntentId': id, 'last4': last4, 'brand': brand};

      debugPrint(
        '🌐 Capture Payment - Endpoint: ${ApiEndpoints.captureStripePayment}',
      );
      debugPrint('📦 Capture Payment - Body: $body');

      final resp = await dioClient.post(
        ApiEndpoints.captureStripePayment,
        data: body,
      );

      debugPrint('✅ Capture Payment - Response: ${resp.data}');

      if (resp.data == null) {
        throw Exception('Null response from capture payment API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in capturePayment: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Creates a bank payment (ACH/Direct Debit)
  ///
  /// [amount] - Amount in smallest currency unit
  /// [currency] - Three-letter ISO currency code
  ///
  /// Returns bank payment data
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> createBankPayment({
    required int amount,
    required String currency,
  }) async {
    try {
      final body = {'amount': amount, 'currency': currency};

      debugPrint(
        '🌐 Create Bank Payment - Endpoint: ${ApiEndpoints.createBankPayment}',
      );
      debugPrint('📦 Create Bank Payment - Body: $body');

      final resp = await dioClient.post(
        ApiEndpoints.createBankPayment,
        data: body,
      );

      debugPrint('✅ Create Bank Payment - Response: ${resp.data}');

      if (resp.data == null) {
        throw Exception('Null response from create bank payment API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in createBankPayment: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendPaymentReceipt({
    required String email,
    required String transactionId,
  }) async {
    try {
      final body = {'email': email, 'transactionId': transactionId};

      debugPrint(
        '🌐 Send Payment Receipt - Endpoint: ${ApiEndpoints.sendPaymentReceipt}',
      );
      debugPrint('📦 Send Payment Receipt - Body: $body');

      final resp = await dioClient.post(
        ApiEndpoints.sendPaymentReceipt,
        data: body,
      );

      debugPrint('✅ Send Payment Receipt - Response: ${resp.data}');

      if (resp.data == null) {
        throw Exception('Null response from send payment receipt API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in sendPaymentReceipt: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  fetchStripeBalance() async {
    try {
      final resp = await dioClient.get(ApiEndpoints.getConnectedAccountBalance);

      debugPrint('🌐 Fetch Stripe Balance - Status: ${resp.statusCode}');
      debugPrint('🌐 Fetch Stripe Balance - Data: ${resp.data}');

      if (resp.data == null) {
        throw Exception('Null response from fetch stripe balance API');
      }

      return resp.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in fetchStripeBalance: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
