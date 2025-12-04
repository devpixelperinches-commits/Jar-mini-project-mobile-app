// lib/core/helpers/api_error_helper.dart
import 'package:dio/dio.dart';

class ApiErrorHelper {
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && (data['message'] != null || data['error'] != null)) {
          return data['message'] ?? data['error'];
        }
        return 'Server error: ${error.response?.statusCode ?? 'Unknown'}';
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please try again.';
      } else if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
