import 'package:flutter/foundation.dart';
import 'package:jarpay/core/network/dio_client.dart';
import 'package:jarpay/core/network/api_endpoints.dart';

class TransctaionsRepository {
  Future<Map<String, dynamic>> fetchTransactionsRepo(
    Map<String, dynamic> map,
  ) async {
    debugPrint('🌐 Calling API: getAllTransactions with params: $map');

    try {
      // ✅ NO TRY-CATCH! Let the interceptor handle errors!
      final resp = await dioClient.post(
        ApiEndpoints.getAllTransactions,
        data: map,
      );

      debugPrint('✅ Response received -----------: $resp');

      return resp.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('⚠️ Artificial delay interrupted --------: $e');
      rethrow;
    }
  }
}
