import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jarpay/core/network/api_endpoints.dart';
import 'package:jarpay/core/network/dio_client.dart';

class PasswordRepository {
  /// 🔹 Forgot Password API
  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> body) async {
    const endpoint = ApiEndpoints.forgotPassword;
    final resp = await dioClient.post(endpoint, data: body);
    return Map<String, dynamic>.from(resp.data);
  }

 
  /// 🔹 Verify Forgot Password OTP
  Future<Map<String, dynamic>> verifyForgotPasswordOtp(Map<String, dynamic> body) async {
    const endpoint = ApiEndpoints.forgotPasswordotp;
    final resp = await dioClient.post(endpoint, data: body);
    return Map<String, dynamic>.from(resp.data);
  }
  

  /// 🔹 Send Change Password OTP (for logged-in user)
  Future<Map<String, dynamic>> sendResetPasswordOtp(Map<String, dynamic> body) async {
  try {
    debugPrint("📤 Send Change Password OTP called with body: $body");
    final resp = await dioClient.post(
      ApiEndpoints.sendChangePasswordOtp,
      data: body, 
    );
    debugPrint("✅ Send Change Password OTP Response: ${resp.data}");
    return Map<String, dynamic>.from(resp.data);
  } on DioException catch (e) {
    debugPrint("❌ Send Change Password OTP Error: $e");
    rethrow;
  }
}


 Future<Map<String, dynamic>> verifyResetPasswordOtp(Map<String, dynamic> body) async {
    const endpoint = ApiEndpoints.changePasswordotp;
    debugPrint("📤 Verify reset Password OTP Payload: $body");
    final resp = await dioClient.post(endpoint, data: body);
    debugPrint("✅ Verify reset Password OTP Response: ${resp.data}");
    return Map<String, dynamic>.from(resp.data);
  }



 Future<Map<String, dynamic>> forgotResetPassword(Map<String, dynamic> body) async {
    const endpoint = ApiEndpoints.resetPassword;
    debugPrint("📤 Verify resetPassword Password OTP Payload: $body");
    final resp = await dioClient.post(endpoint, data: body);
    debugPrint("✅ Verify resetPassword Password OTP Response: ${resp.data}");
    return Map<String, dynamic>.from(resp.data);
  }


   Future<Map<String, dynamic>> resedOtp(Map<String, dynamic> body) async {
    const endpoint = ApiEndpoints.resendOtp;
    debugPrint("📤 Resend Forgot Password OTP Payload: $body");
    final resp = await dioClient.post(endpoint, data: body);
    debugPrint("✅ Resend Forgot Password OTP Response: ${resp.data}");
    return Map<String, dynamic>.from(resp.data);
  }

}
