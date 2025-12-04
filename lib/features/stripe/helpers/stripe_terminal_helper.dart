// stripe_terminal_helper.dart
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/core/utils/device_location_helper.dart';
import 'package:jarpay/features/stripe/provider/stripe_notifier.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'my_reader_delegate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Optimized Stripe Terminal helper:
/// - Single initialization guard
/// - Bounded retries with exponential backoff for token fetch
/// - Timeouts for long blocking operations
/// - Safe disconnect/cleanup
/// - Minimal UI blocking (no infinite loops)
class StripeTerminalHelper {
  // ======== Configuration ========
  static const int _tokenFetchRetries = 3;
  static const Duration _tokenRequestTimeout = Duration(seconds: 6);
  static const Duration _discoverTimeout = Duration(seconds: 12);
  static const Duration _connectTimeout = Duration(seconds: 12);

  // ======== Internal state ========
  static Terminal? _terminal;
  static Reader? connectedReader;
  static bool _isInitializing = false;
  static bool _initialized = false;

  // ========== Utilities ==========
  static void _log(String msg) => debugPrint('StripeTerminalHelper: $msg');

  // ========== Reset/Cleanup ==========
  /// Resets internal state and attempts to disconnect gracefully.
  /// Safe to call multiple times.
  static Future<void> resetTerminal() async {
    try {
      if (connectedReader != null && _terminal != null) {
        try {
          await _terminal!.disconnectReader().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              _log('disconnectReader timed out');
              return;
            },
          );
          _log('✅ Reader disconnected during reset');
        } catch (e) {
          _log('⚠️ Error while disconnecting reader: $e');
        }
      }
    } catch (e) {
      _log('⚠️ Failed to reset terminal: $e');
    } finally {
      _terminal = null;
      connectedReader = null;
      _initialized = false;
      _isInitializing = false;
      _log('🔄 Terminal state reset');
    }
  }

  // ========== Initialization ==========
  /// Initializes terminal once. Safe to call multiple times from different places.
  /// Will not attempt a second init while a first init is in progress.
  static Future<void> init({bool forceReset = false}) async {
    if (_initialized && !forceReset) {
      _log('Already initialized - skipping init()');
      return;
    }

    if (_isInitializing) {
      _log('Initialization already in progress - waiting');
      // Wait until current init finishes (but don't wait forever)
      final sw = Stopwatch()..start();
      while (_isInitializing && sw.elapsed.inSeconds < 15) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
      if (_initialized) {
        _log('Initialization completed by another caller.');
        return;
      }
      if (_isInitializing) {
        throw Exception('Terminal initialization timeout.');
      }
    }

    _isInitializing = true;

    if (forceReset) {
      await resetTerminal();
    }

    try {
      _log('Initializing Terminal...');
      // Wrap init in a microtask to reduce chance of blocking UI synchronous work
      await Future.microtask(() async {
        await Terminal.initTerminal(
          shouldPrintLogs: true,
          fetchToken: fetchConnectionToken,
        ).timeout(const Duration(seconds: 10));
      });

      _terminal = Terminal.instance;
      _initialized = true;
      _log('✅ Terminal initialized successfully');
    } catch (e, st) {
      _log('❌ Failed to initialize Terminal: $e\n$st');
      // Keep _initialized false so callers can re-attempt initialization
      _initialized = false;
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// Returns the Terminal instance or throws if not initialized.
  static Terminal get instance {
    if (_terminal == null) {
      throw Exception(
        "Terminal not initialized. Call StripeTerminalHelper.init() first!",
      );
    }
    return _terminal!;
  }

  // ========== Connection Token (bounded retries + backoff) ==========
  /// Fetches connection token with bounded retries and exponential backoff.
  /// This function will throw after retries are exhausted.
  static Future<String> fetchConnectionToken({int attempt = 0}) async {
    final apiUrl = dotenv.env['API_BASE_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw Exception('API_BASE_URL not found in environment variables');
    }

    final fullUrl = '$apiUrl/user/connection-token';
    final client = Dio();

    try {
      final response = await client
          .post(
            fullUrl,
            // small timeout to avoid hanging the UI
          )
          .timeout(_tokenRequestTimeout);

      // adapt based on your API response shape
      final token = response.data['data']?['secret'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Token missing from response');
      }

      _log(
        "🔑 Got connection token: ${token.substring(0, min(10, token.length))}...",
      );
      return token;
    } catch (e) {
      _log('❌ Error fetching connection token (attempt ${attempt + 1}): $e');

      if (attempt >= _tokenFetchRetries - 1) {
        throw Exception(
          'Failed to fetch connection token after $_tokenFetchRetries attempts.',
        );
      }

      // Exponential backoff with jitter
      final backoffMs = (pow(2, attempt) * 250).toInt();
      final jitter = Random().nextInt(250);
      final wait = Duration(milliseconds: backoffMs + jitter + 250);

      _log('⏳ Retrying fetch token after ${wait.inMilliseconds}ms...');
      await Future.delayed(wait);

      return fetchConnectionToken(attempt: attempt + 1);
    }
  }

  // ========== Permissions ==========
  /// Request and validate Bluetooth & location permissions.
  /// Returns true only if all needed permissions are granted.
  static Future<bool> requestBluetoothPermissions(BuildContext context) async {
    BluetoothAdapterState bluetoothState = BluetoothAdapterState.unknown;

    try {
      bluetoothState = await FlutterBluePlus.adapterState.first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => BluetoothAdapterState.unknown,
      );
    } catch (e) {
      _log('⚠️ Could not get Bluetooth state: $e');
    }

    _log('🔵 Bluetooth State: $bluetoothState');

    if (bluetoothState == BluetoothAdapterState.off) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Bluetooth Required"),
            content: const Text(
              "Please enable Bluetooth in Settings, then return here.",
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(ctx),
              ),
              TextButton(
                child: const Text("Open Settings"),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await AppSettings.openAppSettings(
                    type: AppSettingsType.bluetooth,
                  );
                },
              ),
            ],
          ),
        );
      }
      return false;
    }

    Map<Permission, PermissionStatus> statuses = {};

    if (Platform.isAndroid) {
      statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
    } else if (Platform.isIOS) {
      statuses = await [
        Permission.bluetooth,
        Permission.locationWhenInUse,
      ].request();
    }

    final allGranted = statuses.values.every((s) => s.isGranted);

    if (!allGranted && context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Permissions Required"),
          content: const Text(
            "Please grant Bluetooth and Location permissions to connect to the reader.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () async {
                Navigator.pop(ctx);
                await AppSettings.openAppSettings();
              },
            ),
          ],
        ),
      );
    }

    _log('✅ All permissions granted: $allGranted');
    return allGranted;
  }

  // ========== Discover & Connect ==========
  /// Discover and connect to the first available reader.
  /// Uses timeouts and returns null if no reader connected.
  static Future<Reader?> discoverAndConnect(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (connectedReader != null) {
      _log('ℹ️ Reader already connected: ${connectedReader!.label}');
      return connectedReader;
    }

    if (!_initialized) {
      _log('Terminal not initialized yet. Calling init()...');
      await init();
    }

    try {
      final terminal = instance;
      _log('🔍 Starting reader discovery...');

      // discoverReaders returns a Stream<List<Reader>>
      final readersStream = terminal.discoverReaders(
        const BluetoothDiscoveryConfiguration(isSimulated: false),
      );

      // Wait for the first non-empty list, or timeout
      final readers = await readersStream
          .firstWhere((list) => list.isNotEmpty)
          .timeout(_discoverTimeout, onTimeout: () => <Reader>[]);

      if (readers.isEmpty) {
        _log('⚠️ No readers discovered (or discovery timed out)');
        return null;
      }

      _log('📱 Found ${readers.length} reader(s)');
      final selectedReader = readers.first;
      _log('🔌 Attempting to connect to: ${selectedReader.label}');

      final connected = await terminal
          .connectReader(
            selectedReader,
            configuration: BluetoothConnectionConfiguration(
              locationId: selectedReader.locationId ?? '',
              readerDelegate: MyReaderDelegate(),
              autoReconnectOnUnexpectedDisconnect: false,
            ),
          )
          .timeout(_connectTimeout);

      _log("✅ Reader connected: ${connected.label}");
      connectedReader = connected;

      // Fire-and-forget: create stripe location, but don't block caller for too long
      unawaited(_postConnectTasks(selectedReader, ref, context));

      return connected;
    } catch (e, st) {
      _log('❌ Error during reader discovery/connection: $e\n$st');
      return null;
    }
  }

  // Helper for post connect tasks (location creation, etc.) – non-blocking
  static Future<void> _postConnectTasks(
    Reader selectedReader,
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      final deviceLocationData =
          await DeviceLocationHelper.getDeviceAndLocation().timeout(
            const Duration(seconds: 8),
          );
      final userAddress =
          deviceLocationData.userLocation.address ?? 'Address not available';
      final latitude = deviceLocationData.userLocation.latitude;
      final longitude = deviceLocationData.userLocation.longitude;
      final readerLocationId = selectedReader.locationId ?? '';

      _log('📍 User Address: $userAddress');
      _log('📍 Coordinates: $latitude, $longitude');
      _log('📍 Reader Location ID: $readerLocationId');

      final notifier = ref.read(stripeNotifierProvider.notifier);
      final locationAddress = userAddress.isNotEmpty
          ? "$userAddress (Reader: $readerLocationId)"
          : "Reader Location ID: $readerLocationId";

      final res = await notifier
          .createStripeLocation(address: locationAddress)
          .timeout(const Duration(seconds: 6));
      if (res != null && (res['success'] ?? false)) {
        _log('✅ Stripe location created successfully');
      } else {
        _log('⚠️ Failed to create Stripe location');
      }
    } catch (e) {
      _log('⚠️ Error in post-connect tasks: $e');
    }
  }

  // ========== Disconnect ==========
  /// Disconnect the connected reader gracefully.
  static Future<void> disconnectReader() async {
    if (connectedReader == null) {
      _log('ℹ️ No reader to disconnect');
      return;
    }

    if (!_initialized) {
      _log('Terminal not initialized; nothing to disconnect');
      connectedReader = null;
      return;
    }

    try {
      final terminal = instance;
      await terminal.disconnectReader().timeout(const Duration(seconds: 6));
      _log('✅ Reader disconnected');
    } catch (e) {
      _log('❌ Error disconnecting reader: $e');
    } finally {
      connectedReader = null;
    }
  }

  // ========== Helpers ==========
  static bool isReaderConnected() => connectedReader != null;
  static Reader? getConnectedReader() => connectedReader;
  static void clearConnection() {
    connectedReader = null;
    _log('🔄 Connection cleared');
  }
}

/// Small helper for unawaited Futures without import issues.
void unawaited(Future<void> f) {}
