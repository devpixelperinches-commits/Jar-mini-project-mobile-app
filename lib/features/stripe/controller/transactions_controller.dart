import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/provider/transactions_notifier.dart';

/// Provider for managing loading state during stripe operations
final stripeLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for TransactionsController instance
final transactionsControllerProvider = Provider<TransactionsController>(
  (ref) => TransactionsController(ref),
);

class TransactionsController {
  final Ref ref;

  TransactionsController(this.ref);

  /// Fetch transactions safely with retries handled by AuthInterceptor
  Future<Map<String, dynamic>> fetchTransactions({
    required String startDate,
    required String endDate,
    required int page,
    required int limit,
  }) async {
    debugPrint('🔵 Controller: Fetching transactions...');

    final notifier = ref.read(transactionsNotifierProvider.notifier);

    // ✅ NO TRY-CATCH! Let the interceptor work!
    final result = await notifier.fetchTransactionsNotifier(
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );

    debugPrint(
      '✅ Controller: Got ${result['transactions']?.length ?? 0} transactions',
    );
    return result;
  }

  /// Fetch transactions with default pagination safely
  Future<Map<String, dynamic>> fetchTransactionsDefault({
    required String startDate,
    required String endDate,
  }) async {
    return fetchTransactions(
      startDate: startDate,
      endDate: endDate,
      page: 1,
      limit: 20,
    );
  }
}
