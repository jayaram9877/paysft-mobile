/// A builder-curated point of interest near a project ("Places nearby").
class NearbyPlace {
  final String name;
  final String? category;
  final String? distance;

  NearbyPlace({required this.name, this.category, this.distance});

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      name: (json['name'] as String?) ?? '',
      category: json['category']?.toString(),
      distance: json['distance']?.toString(),
    );
  }
}

/// Mirrors the API `BrokerProjectResponse` (a live project a broker can browse).
/// The list and detail endpoints return the same schema, so this model covers
/// both the card and the project-detail view.
class BrokerProjectModel {
  final String id;
  final String name;
  final String state;
  final String city;
  final String locality;
  final String? projectType;
  final String? projectSubtype;
  final String? constructionStatus;
  final String? coverImageUrl;
  final int? totalUnitsPlanned;

  // Richer fields used by the project-detail view.
  final String? description;
  final String? reraProjectNumber;
  final String? reraProjectState;
  final String? pincode;
  final String? totalAcres;
  final String? totalBuiltUpAreaSqft;
  final String? launchDate;
  final String? possessionDate;
  final String? videoUrl;
  final List<String> amenities;
  final String? tagline;
  final String? googleMapsLink;
  final String? cityId;
  final List<NearbyPlace> placesNearby;

  BrokerProjectModel({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.locality,
    this.projectType,
    this.projectSubtype,
    this.constructionStatus,
    this.coverImageUrl,
    this.totalUnitsPlanned,
    this.description,
    this.reraProjectNumber,
    this.reraProjectState,
    this.pincode,
    this.totalAcres,
    this.totalBuiltUpAreaSqft,
    this.launchDate,
    this.possessionDate,
    this.videoUrl,
    this.amenities = const [],
    this.tagline,
    this.googleMapsLink,
    this.cityId,
    this.placesNearby = const [],
  });

  /// Safe string coercion — the API sometimes returns numeric values (e.g.
  /// pincode) where a string is expected; a raw `as String?` cast would throw
  /// and break the whole list parse.
  static String? _s(dynamic v) => v?.toString();

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory BrokerProjectModel.fromJson(Map<String, dynamic> json) {
    return BrokerProjectModel(
      id: _s(json['id']) ?? '',
      name: _s(json['name']) ?? 'Untitled Project',
      state: _s(json['state']) ?? '',
      city: _s(json['city']) ?? '',
      locality: _s(json['locality']) ?? '',
      projectType: _s(json['project_type']),
      projectSubtype: _s(json['project_subtype']),
      constructionStatus: _s(json['construction_status']),
      coverImageUrl: _s(json['cover_image_url']),
      totalUnitsPlanned: _toInt(json['total_units_planned']),
      description: _s(json['description']),
      reraProjectNumber: _s(json['rera_project_number']),
      reraProjectState: _s(json['rera_project_state']),
      pincode: _s(json['pincode']),
      totalAcres: _s(json['total_acres']),
      totalBuiltUpAreaSqft: _s(json['total_built_up_area_sqft']),
      launchDate: _s(json['launch_date']),
      possessionDate: _s(json['possession_date']),
      videoUrl: _s(json['video_url']),
      amenities: _parseAmenities(json['amenities']),
      tagline: _s(json['tagline']),
      googleMapsLink: _s(json['google_maps_link']),
      cityId: _s(json['city_id']),
      placesNearby: _parsePlaces(json['places_nearby']),
    );
  }

  static List<NearbyPlace> _parsePlaces(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => NearbyPlace.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.name.isNotEmpty)
        .toList();
  }

  /// `amenities` may be a list of strings, a list of objects with a name/label,
  /// or a map. Extract whatever human-readable labels we can.
  static List<String> _parseAmenities(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) {
            if (e is String) return e;
            if (e is Map) {
              return (e['name'] ?? e['label'] ?? e['title'] ?? '').toString();
            }
            return e?.toString() ?? '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is Map) {
      return raw.entries
          .where((e) => e.value == true || e.value == null || e.value is String)
          .map((e) => e.value is String ? e.value.toString() : e.key.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String get location {
    final parts = [locality, city].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  static String pretty(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    return raw
        .split(RegExp(r'[_\s]+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String get typeLabel => pretty(projectSubtype ?? projectType);
  String get statusLabel => pretty(constructionStatus);
}
