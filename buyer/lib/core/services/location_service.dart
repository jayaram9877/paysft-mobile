import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import 'location_platform.dart';

class LocationService {
  final LocationPlatform _platform;

  LocationService([LocationPlatform? platform])
      : _platform = platform ?? _GeolocatorLocationPlatform();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await _platform.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await _platform.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.denied;
    }

    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await _platform.requestPermission();
    }

    return permission;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    return await _platform.getCurrentPosition();
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied() async {
    final status = await permission_handler.Permission.location.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await permission_handler.openAppSettings();
  }
}

class _GeolocatorLocationPlatform implements LocationPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      } else if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }
}

