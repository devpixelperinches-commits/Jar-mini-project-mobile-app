import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/data/transactions_repository.dart';

final transactionsNotifierProvider =
    StateNotifierProvider<
      TransactionsNotifier,
      AsyncValue<Map<String, dynamic>>
    >((ref) => TransactionsNotifier(TransctaionsRepository()));

class TransactionsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final TransctaionsRepository _repo;
  TransactionsNotifier(this._repo)
    : super(const AsyncValue.data({'transactions': [], 'meta': {}}));

  Future<Map<String, dynamic>> fetchTransactionsNotifier({
    String? startDate,
    String? endDate,
    required int page,
    required int limit,
  }) async {
    debugPrint('🔵 Notifier: Starting fetch...');

    final start = startDate ?? "";
    final end = endDate ?? "";

    state = const AsyncValue.loading();

    // ✅ NO TRY-CATCH! Let errors propagate naturally
    final res = await _repo.fetchTransactionsRepo({
      'startDate': start,
      'endDate': end,
      'page': page,
      'limit': limit,
    });

    debugPrint(
      '✅ Notifier: Got response with ${res['transactions']?.length ?? 0} transactions',
    );
    state = AsyncValue.data(res);
    return res;
  }
}
