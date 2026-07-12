class LocationSuggestion {
  /// The primary matched place, e.g. "Gachibowli" (a locality) or "Hyderabad".
  final String name;

  /// The administrative city the place belongs to, used to resolve a backend
  /// city id. For a top-level city this equals [name]; for a locality it's the
  /// parent city (e.g. "Hyderabad" for "Gachibowli"). May be empty.
  final String city;

  final String state;
  final String country;
  final String displayName;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  /// Title shown in the results list (the thing the user searched for).
  String get title => name.isNotEmpty ? name : city;

  /// Secondary context line: parent city (if different) + state.
  String get subtitle {
    final parts = <String>[];
    if (city.isNotEmpty && city != title) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (parts.isEmpty && country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  /// City name used to resolve a backend city id (`/buyer/cities`).
  String get resolveCity => city.isNotEmpty ? city : name;

  /// Full label persisted as the selected location.
  String get fullName {
    final parts = <String>[title];
    if (city.isNotEmpty && city != title) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }
}
