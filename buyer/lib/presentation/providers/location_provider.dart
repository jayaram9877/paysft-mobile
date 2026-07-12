import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/entities/location_suggestion.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;
  final LocationRepository _locationRepository;
  final LocalStorageService _localStorageService;
  final HomeRepository _homeRepository;

  LocationProvider({
    required LocationService locationService,
    required LocationRepository locationRepository,
    required LocalStorageService localStorageService,
    required HomeRepository homeRepository,
    bool initializeOnCreate = true,
  })  : _locationService = locationService,
        _locationRepository = locationRepository,
        _localStorageService = localStorageService,
        _homeRepository = homeRepository {
    if (initializeOnCreate) {
      _initializeLocation();
    }
  }

  String _selectedLocation = 'Select Location';
  String get selectedLocation => _selectedLocation;

  /// Backend city id (`/buyer/cities`.id) for the selected location, used to
  /// filter the property catalog. Null when unresolved (shows the whole catalog).
  String? _selectedCityId;
  String? get selectedCityId => _selectedCityId;

  /// Last picked coordinates, so the map picker can reopen where it left off.
  double? _selectedLatitude;
  double? _selectedLongitude;
  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDetectingLocation = false;
  bool get isDetectingLocation => _isDetectingLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize location on app start.
  Future<void> _initializeLocation() async {
    final savedLocation = await _localStorageService.getSelectedLocation();
    if (savedLocation != null && savedLocation.isNotEmpty) {
      _selectedLocation = savedLocation;
      _selectedCityId = await _localStorageService.getSelectedCityId();
      _selectedLatitude = await _localStorageService.getSelectedLatitude();
      _selectedLongitude = await _localStorageService.getSelectedLongitude();
      notifyListeners();
      return;
    }

    // No saved location yet — detect it in the background (non-blocking).
    detectCurrentLocation();
  }

  /// Detect current location using GPS, then reverse-geocode to a city.
  Future<void> detectCurrentLocation() async {
    _isDetectingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        _errorMessage = 'Location services are disabled. Please enable them in settings.';
        return;
      }

      final permission = await _locationService.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _errorMessage = permission == LocationPermission.deniedForever
            ? 'Location permission is permanently denied. Please enable it in settings.'
            : 'Location permission was denied. Please allow location access to use this feature.';
        return;
      }

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _errorMessage = 'Unable to get your location. Please select a city manually.';
        return;
      }

      final cityName = await _locationRepository.getCityNameFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (cityName != null && cityName.isNotEmpty) {
        await _applyLocation(
          cityName,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _errorMessage = null;
      } else {
        _errorMessage = 'Could not determine your city. Please select manually.';
      }
    } catch (e) {
      _errorMessage = 'Error detecting location: ${e.toString()}';
    } finally {
      _isDetectingLocation = false;
      notifyListeners();
    }
  }

  /// Update the selected location from a manual pick (search result or map pin).
  /// [cityName] is the bare city used to resolve the backend city id; when
  /// omitted, [location] is used.
  Future<void> updateLocation(
    String location, {
    String? cityName,
    double? latitude,
    double? longitude,
  }) async {
    await _applyLocation(
      location,
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  /// Resolves [display] to a backend city id and persists it (plus any
  /// coordinates). Does NOT notify on its own when called from
  /// [detectCurrentLocation] (which notifies in its finally block);
  /// [updateLocation] notifies for manual picks.
  Future<void> _applyLocation(
    String display, {
    String? cityName,
    double? latitude,
    double? longitude,
  }) async {
    _selectedLocation = display;
    if (latitude != null && longitude != null) {
      _selectedLatitude = latitude;
      _selectedLongitude = longitude;
    }
    String? cityId;
    try {
      final match = await _homeRepository.findCity(cityName ?? display);
      cityId = match?.id;
    } catch (_) {
      cityId = null;
    }
    _selectedCityId = cityId;
    await _localStorageService.saveSelectedLocation(
      display,
      cityId: cityId,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
    );
  }

  /// Reverse-geocode arbitrary coordinates to a city label (used by the map
  /// picker as the pin moves).
  Future<String?> cityNameForCoordinates(double latitude, double longitude) {
    return _locationRepository.getCityNameFromCoordinates(latitude, longitude);
  }

  /// Search for cities (OpenStreetMap Nominatim).
  Future<List<LocationSuggestion>> searchCities(String query) async {
    if (query.isEmpty) return [];

    _isLoading = true;
    notifyListeners();
    try {
      return await _locationRepository.searchCities(query);
    } catch (e) {
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open app settings for location permission.
  Future<void> openLocationSettings() async {
    await _locationService.openAppSettings();
  }
}
