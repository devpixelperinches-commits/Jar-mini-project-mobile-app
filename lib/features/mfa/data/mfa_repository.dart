import 'package:jarpay/core/network/api_endpoints.dart';
import 'package:jarpay/core/network/dio_client.dart';

class MfaRepository {
  /// Enable MFA (no body)
  Future<Map<String, dynamic>> enableMfa() async {

  final resp = await dioClient.post(ApiEndpoints.mfaSetup);

  return Map<String, dynamic>.from(resp.data);
}


  /// Verify MFA
  Future<Map<String, dynamic>> verifyMfa(Map<String, dynamic> body) async {

    final resp = await dioClient.post(ApiEndpoints.mfaVerify, data: body);

    return Map<String, dynamic>.from(resp.data);
  }

  /// Disable MFA
  Future<Map<String, dynamic>> disableMfa() async {

    final resp = await dioClient.post(ApiEndpoints.disableMfa);

    return Map<String, dynamic>.from(resp.data);
  }
}
