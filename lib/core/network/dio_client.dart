import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptors.dart';

// ✅ Create immediately, no late keyword needed
final Dio dioClient = _createDioClient();

Dio _createDioClient() {
  final baseUrl = dotenv.env['API_BASE_URL'] ??
      const String.fromEnvironment('API_BASE_URL', defaultValue: '');
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (status) {
        debugPrint('✅ DIO CLIENT--- $status'); // <-- Add this

        return status != null && status < 400;
      },
    ),
  );

  if (!kIsWeb) {
    _configureCertificatePinning(dio);
  }

  // Add interceptor
  dio.interceptors.add(AuthInterceptor(dio));
  debugPrint(
    '✅ DIO CLIENT CREATED WITH ${dio.interceptors.length} INTERCEPTORS',
  ); // <-- Add this

  return dio;
}

void _configureCertificatePinning(Dio dio) {
  final certBase64 = dotenv.env['PINNED_CERT_BASE64'] ??
      const String.fromEnvironment('PINNED_CERT_BASE64', defaultValue: '');

  if (certBase64.isEmpty) {
    return;
  }

  try {
    final certBytes = base64Decode(certBase64);
    final context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(certBytes);

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(context: context);
        client.badCertificateCallback = (cert, host, port) {
          final digest =
              sha256.convert(cert.der).bytes; // Validate presented cert
          final presentedFingerprint = base64Encode(digest);
          final trustedFingerprint =
              base64Encode(sha256.convert(certBytes).bytes);
          return presentedFingerprint == trustedFingerprint;
        };
        return client;
      },
    );
  } catch (e, stackTrace) {
    debugPrint('⚠️ Failed to configure TLS pinning: $e');
    debugPrint('$stackTrace');
  }
}
