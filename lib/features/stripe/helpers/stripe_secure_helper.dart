// features/stripe/utils/security_helpers.dart
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

final _secureStorage = const FlutterSecureStorage();

// --- Secure storage helpers ---
Future<void> secureWrite(String key, String value) =>
    _secureStorage.write(key: key, value: value);

Future<String?> secureRead(String key) => _secureStorage.read(key: key);

// --- Helper to generate random state (if needed client-side) ---
String generateNonce([int length = 32]) {
  const charset =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rnd = Random.secure();
  return List.generate(
    length,
    (_) => charset[rnd.nextInt(charset.length)],
  ).join();
}

// --- Whitelisted and validated URL launcher ---
Future<void> safeLaunchUrl(String urlString) async {
  final uri = Uri.tryParse(urlString);
  if (uri == null || !uri.isAbsolute || uri.scheme != 'https') {
    throw Exception('Invalid or non-HTTPS URL.');
  }

  // Whitelist hosts: accept either Stripe connect or your backend proxy
  const allowedHosts = [
    'connect.stripe.com',
    'hooks.stripe.com',
    'mini-project.sumit-176.workers.dev',
    'your-backend.com',
  ];
  if (!allowedHosts.any((h) => uri.host.contains(h))) {
    throw Exception('Untrusted onboarding host: ${uri.host}');
  }

  if (!await canLaunchUrl(uri)) {
    throw Exception('Could not launch URL');
  }

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
