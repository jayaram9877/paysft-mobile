import 'package:geolocator/geolocator.dart';

/// Abstraction for location/geolocator operations to allow testing.
abstract class LocationPlatform {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position?> getCurrentPosition();
}
