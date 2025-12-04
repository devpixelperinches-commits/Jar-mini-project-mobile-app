import 'package:jarpay/core/network/api_endpoints.dart';
import 'package:jarpay/core/network/dio_client.dart';

class OtpRepository {
  /// Verify OTP API
  Future<Map<String, dynamic>> verifyOtp(
    Map<String, dynamic> body, {
    bool isSignup = false,
  }) async {
    final endpoint = isSignup
        ? ApiEndpoints.verifySignupOtp
        : ApiEndpoints.verifyOtp;

    final resp = await dioClient.post(endpoint, data: body);

    return Map<String, dynamic>.from(resp.data);
  }
}
