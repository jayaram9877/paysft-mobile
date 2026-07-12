import '../entities/location_suggestion.dart';

abstract class LocationRepository {
  /// Convert latitude and longitude to city name
  Future<String?> getCityNameFromCoordinates(double latitude, double longitude);

  /// Search for cities based on query string
  Future<List<LocationSuggestion>> searchCities(String query);
}

