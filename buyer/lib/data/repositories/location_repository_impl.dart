import 'dart:convert';
import 'package:buyer/domain/entities/location_suggestion.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../../domain/repositories/location_repository.dart';

/// Optional override for placemark lookup (for testing).
typedef PlacemarkProvider = Future<List<Placemark>> Function(double latitude, double longitude);

/// Location lookups backed by OpenStreetMap Nominatim (primary) with the native
/// platform geocoder as a fallback.
///
/// Nominatim is used first because it works consistently across devices without
/// depending on Google Play Services (the native `geocoding` plugin often
/// returns nothing on de-Googled / non-GMS Android builds).
class LocationRepositoryImpl implements LocationRepository {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Nominatim's usage policy requires a genuine, identifying User-Agent.
  static const String _userAgent = 'PaysftBuyerApp/1.0 (support@paysft.com)';

  final http.Client _client;
  final PlacemarkProvider? _placemarkProvider;

  LocationRepositoryImpl({http.Client? client, PlacemarkProvider? placemarkProvider})
      : _client = client ?? http.Client(),
        _placemarkProvider = placemarkProvider;

  @override
  Future<String?> getCityNameFromCoordinates(double latitude, double longitude) async {
    // Prefer Nominatim; fall back to the native geocoder only if it fails.
    final fromOsm = await _getCityNameFromNominatim(latitude, longitude);
    if (fromOsm != null && fromOsm.isNotEmpty) return fromOsm;

    try {
      final provider = _placemarkProvider;
      final List<Placemark> placemarks = provider != null
          ? await provider(latitude, longitude)
          : await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.subAdministrativeArea ?? '';
        final region = place.administrativeArea ?? place.country ?? '';
        if (city.isNotEmpty) {
          return region.isNotEmpty ? '$city, $region' : city;
        }
      }
    } catch (_) {
      // Both providers failed.
    }
    return null;
  }

  Future<String?> _getCityNameFromNominatim(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=10&addressdetails=1',
      );

      final response = await _client.get(url, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) return null;

      final city = (address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'] ??
              '')
          .toString();
      // Prefer the state/region over the country for an India-centric app.
      final region = (address['state'] ?? address['country'] ?? '').toString();

      if (city.isEmpty) return null;
      return region.isNotEmpty ? '$city, $region' : city;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LocationSuggestion>> searchCities(String query) async {
    try {
      // Bias results to India (the backend catalog is Indian). We intentionally
      // do NOT set featureType=city — that drops localities/suburbs (e.g.
      // "Gachibowli"), which are exactly what buyers search for.
      final url = Uri.parse(
        '$_nominatimBaseUrl/search'
        '?format=json&q=${Uri.encodeQueryComponent(query)}'
        '&countrycodes=in&limit=10&addressdetails=1',
      );

      final response = await _client.get(url, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return [];

      final List<dynamic> data = json.decode(response.body);
      final seen = <String>{};
      final results = <LocationSuggestion>[];
      for (final item in data) {
        final address = item['address'] as Map<String, dynamic>?;
        final display = (item['display_name'] ?? '').toString();

        // Primary label: the matched place itself (first component / OSM name).
        final name = (item['name']?.toString().trim().isNotEmpty ?? false)
            ? item['name'].toString().trim()
            : display.split(',').first.trim();

        // Administrative city used for backend resolution.
        final city = (address?['city'] ??
                address?['town'] ??
                address?['village'] ??
                address?['municipality'] ??
                address?['county'] ??
                '')
            .toString();
        final state = (address?['state'] ?? '').toString();
        final country = (address?['country'] ?? '').toString();

        if (name.isEmpty) continue;
        // De-duplicate identical "name + city" entries Nominatim often repeats.
        if (!seen.add('${name.toLowerCase()}|${city.toLowerCase()}')) continue;

        results.add(LocationSuggestion(
          name: name,
          city: city,
          state: state,
          country: country,
          displayName: display,
          latitude: double.tryParse(item['lat']?.toString() ?? '') ?? 0.0,
          longitude: double.tryParse(item['lon']?.toString() ?? '') ?? 0.0,
        ));
      }
      return results;
    } catch (_) {
      return [];
    }
  }
}
