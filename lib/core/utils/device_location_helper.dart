import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jarpay/core/network/api_endpoints.dart';
import 'package:jarpay/core/network/dio_client.dart';

/// Response wrapper for device and location data
class DeviceLocationData {
  final DeviceInfo deviceInfo;
  final UserLocation userLocation;

  DeviceLocationData({required this.deviceInfo, required this.userLocation});

  Map<String, dynamic> toJson() => {
    'deviceInfo': deviceInfo.toJson(),
    'userCurrentLocation': userLocation.toJson(),
  };

  @override
  String toString() => jsonEncode(toJson());

  void operator [](String other) {}
}

/// Device information model
class DeviceInfo {
  final String? ipAddress;
  final String? modelNumber;
  final String? deviceName;
  final String? osVersion;
  final String platform;

  DeviceInfo({
    this.ipAddress,
    this.modelNumber,
    this.deviceName,
    this.osVersion,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
    'ipAddress': ipAddress,
    'modelNumber': modelNumber,
    'deviceName': deviceName,
    'osVersion': osVersion,
    'platform': platform,
  };

  @override
  String toString() => jsonEncode(toJson());
}

/// User location model
class UserLocation {
  final String? address;
  final String? country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? postalCode;

  UserLocation({
    this.address,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.city,
    this.postalCode,
  });

  bool get isValid => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
    'address': address,
    'country': country,
    'code': countryCode,
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'postalCode': postalCode,
  };

  @override
  String toString() => jsonEncode(toJson());
}

/// Enhanced helper for fetching device info and location
class DeviceLocationHelper {
  static const Duration _defaultTimeout = Duration(seconds: 10);

  /// ✅ Fetch both device info and location with type-safe models
  static Future<DeviceLocationData> getDeviceAndLocation({
    Duration timeout = _defaultTimeout,
    bool includeIpAddress = true,
  }) async {
    try {
      final results = await Future.wait([
        _getDeviceInfo(timeout: timeout, includeIpAddress: includeIpAddress),
        _getLocation(timeout: timeout),
      ]);

      return DeviceLocationData(
        deviceInfo: results[0] as DeviceInfo,
        userLocation: results[1] as UserLocation,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching device and location: $e');
      }
      rethrow;
    }
  }

  /// ✅ Get device info (model, name, IP, OS version)
  static Future<DeviceInfo> _getDeviceInfo({
    Duration timeout = _defaultTimeout,
    bool includeIpAddress = true,
  }) async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String? modelNumber;
    String? deviceName;
    String? osVersion;
    String platform = 'unknown';

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        modelNumber = androidInfo.model;
        deviceName = androidInfo.device;
        osVersion = 'Android ${androidInfo.version.release}';
        platform = 'android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        modelNumber = iosInfo.utsname.machine;
        deviceName = iosInfo.name;
        osVersion = 'iOS ${iosInfo.systemVersion}';
        platform = 'ios';
      } else if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        modelNumber = webInfo.browserName.name;
        deviceName = webInfo.platform ?? 'Web';
        osVersion = webInfo.userAgent;
        platform = 'web';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        modelNumber = macInfo.model;
        deviceName = macInfo.computerName;
        osVersion = macInfo.osRelease;
        platform = 'macos';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        modelNumber = windowsInfo.productName;
        deviceName = windowsInfo.computerName;
        osVersion = windowsInfo.displayVersion;
        platform = 'windows';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        modelNumber = linuxInfo.prettyName;
        deviceName = linuxInfo.name;
        osVersion = linuxInfo.version;
        platform = 'linux';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error getting device info: $e');
      }
    }

    String? ipAddress;
    if (includeIpAddress) {
      ipAddress = await _getIpAddress(timeout: timeout);
    }

    return DeviceInfo(
      ipAddress: ipAddress,
      modelNumber: modelNumber,
      deviceName: deviceName,
      osVersion: osVersion,
      platform: platform,
    );
  }

  /// ✅ Get location with improved error handling and address formatting
  static Future<UserLocation> _getLocation({
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          debugPrint('⚠️ Location services are disabled');
        }
        return UserLocation();
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            debugPrint('⚠️ Location permission denied');
          }
          return UserLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          debugPrint('⚠️ Location permission permanently denied');
        }
        return UserLocation();
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );

      // Reverse geocoding to get address details
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(timeout);

        if (placemarks.isEmpty) {
          return UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }

        final place = placemarks.first;
        final addressParts = <String>[];

        // Build address string from available parts
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        return UserLocation(
          address: addressParts.isNotEmpty ? addressParts.join(', ') : null,
          country: place.country,
          countryCode: place.isoCountryCode,
          latitude: position.latitude,
          longitude: position.longitude,
          city: place.locality,
          postalCode: place.postalCode,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error during reverse geocoding: $e');
        }
        // Return location with coordinates only if geocoding fails
        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⚠️ Location request timed out');
      }
      return UserLocation();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error getting location: $e');
      }
      return UserLocation();
    }
  }

  /// ✅ Get public IP address through backend to avoid leaking data to vendors
  static Future<String?> _getIpAddress({
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final response = await dioClient
          .get(
            ApiEndpoints.deviceIp,
            options: Options(
              receiveTimeout: timeout,
              sendTimeout: timeout,
            ),
          )
          .timeout(timeout);

      final data = response.data;
      if (data is Map && data['ip'] != null) {
        return data['ip'].toString();
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to fetch IP address from backend: $e');
      }
    }
    return null;
  }

  /// ✅ Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// ✅ Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// ✅ Open app settings for location permission
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// ✅ Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// ✅ Get last known position (faster, less battery)
  static Future<UserLocation?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error getting last known location: $e');
      }
      return null;
    }
  }
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/// Example 1: Basic usage
/*
Future<void> fetchDeviceAndLocation() async {
  try {
    final data = await DeviceLocationHelper.getDeviceAndLocation();
    
    print('Device: ${data.deviceInfo.deviceName}');
    print('Model: ${data.deviceInfo.modelNumber}');
    print('IP: ${data.deviceInfo.ipAddress}');
    print('Location: ${data.userLocation.address}');
    print('Coordinates: ${data.userLocation.latitude}, ${data.userLocation.longitude}');
  } catch (e) {
    print('Error: $e');
  }
}
*/

/// Example 2: Check permissions before fetching
/*
Future<void> fetchLocationWithPermissionCheck() async {
  final hasPermission = await DeviceLocationHelper.isLocationPermissionGranted();
  
  if (!hasPermission) {
    print('Location permission not granted');
    await DeviceLocationHelper.openAppSettings();
    return;
  }
  
  final data = await DeviceLocationHelper.getDeviceAndLocation();
  print('Location data: ${data.userLocation}');
}
*/

/// Example 3: Get last known location (faster)
/*
Future<void> getQuickLocation() async {
  final location = await DeviceLocationHelper.getLastKnownLocation();
  
  if (location != null && location.isValid) {
    print('Last known position: ${location.latitude}, ${location.longitude}');
  } else {
    print('No cached location available');
  }
}
*/

/// Example 4: Custom timeout and skip IP
/*
Future<void> fetchWithCustomOptions() async {
  final data = await DeviceLocationHelper.getDeviceAndLocation(
    timeout: Duration(seconds: 5),
    includeIpAddress: false, // Skip IP lookup for faster response
  );
  
  print('Device info: ${data.deviceInfo}');
}
*/

/// Example 5: Convert to JSON for API calls
/*
Future<void> sendToApi() async {
  final data = await DeviceLocationHelper.getDeviceAndLocation();
  
  // Convert to JSON
  final jsonData = data.toJson();
  
  // Send to API
  final response = await dio.post('/api/device-info', data: jsonData);
  print('Response: ${response.data}');
}
*/
