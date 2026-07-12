import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../domain/entities/property_details_model.dart';
import '../../../domain/entities/property_model.dart';
import '../property_details_local_data_source.dart';

abstract class PropertyDetailsRemoteDataSource {
  Future<PropertyDetailsModel> getPropertyDetails(PropertyModel property);
}

/// Fetches real project details from the PaySFT demo backend and maps them onto
/// [PropertyDetailsModel]. Fields the API provides (name, location, description,
/// media gallery, RERA, geo, nearby connectivity, unit pricing) are populated
/// from the API; fields with no API source (agent, EMI, milestones, bed/bath)
/// reuse the mock defaults so the existing page renders fully.
class PropertyDetailsRemoteDataSourceImpl
    implements PropertyDetailsRemoteDataSource {
  final Dio dio;
  final PropertyDetailsLocalDataSource defaults;

  PropertyDetailsRemoteDataSourceImpl({
    required this.dio,
    required this.defaults,
  });

  @override
  Future<PropertyDetailsModel> getPropertyDetails(PropertyModel property) async {
    // Defaults for fields the backend doesn't expose.
    final base = await defaults.getPropertyDetails(property);

    try {
      final projectResp =
          await dio.get('${ApiConstants.buyerProjects}/${property.id}');
      final project = projectResp.data;
      if (project is! Map<String, dynamic>) return base;

      final images = await _fetchMediaImages(property.id);
      final rawUnits = await _fetchUnits(property.id);
      final pricing = _firstUnitPricing(rawUnits);
      final units = _mapUnits(rawUnits);

      return _merge(property, project, images, pricing, units, base);
    } catch (_) {
      // Any failure -> render with defaults rather than an error screen.
      return base;
    }
  }

  Future<List<String>> _fetchMediaImages(String id) async {
    try {
      final resp = await dio.get('${ApiConstants.buyerProjects}/$id/media');
      final data = resp.data;
      final list = data is Map ? data['items'] : data;
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .where((m) {
            final t = '${m['media_type']}';
            return t == 'image' || t == 'floor_plan' || t == 'master_plan';
          })
          .map((m) => '${m['url'] ?? ''}')
          .where((u) => u.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUnits(String id) async {
    try {
      final resp = await dio.get('${ApiConstants.buyerProjects}/$id/units');
      final data = resp.data;
      final list = data is Map ? data['items'] : data;
      if (list is! List) return const [];
      return list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic>? _firstUnitPricing(List<Map<String, dynamic>> units) {
    if (units.isEmpty) return null;
    final withPricing = units.firstWhere(
      (u) => u['pricing'] is Map,
      orElse: () => const {},
    );
    final pricing = withPricing['pricing'];
    return pricing is Map ? Map<String, dynamic>.from(pricing) : null;
  }

  List<UnitInfo> _mapUnits(List<Map<String, dynamic>> units) {
    return units.map((u) {
      final pricing = u['pricing'];
      final priceSource = pricing is Map
          ? (pricing['total_price'] ?? pricing['base_price'])
          : null;
      final title = _str(u['property_title']);
      final number = _str(u['unit_number']) ?? '';
      return UnitInfo(
        id: '${u['id'] ?? ''}',
        unitNumber: number,
        unitType: _pretty(_str(u['unit_type'])),
        title: (title != null && title.isNotEmpty)
            ? title
            : (number.isNotEmpty ? 'Unit $number' : 'Unit'),
        inventoryStatus: _str(u['inventory_status']) ?? '',
        priceLabel: _inr(priceSource),
        attributes: u['attributes'] is Map
            ? Map<String, dynamic>.from(u['attributes'])
            : const {},
        pricing: pricing is Map
            ? Map<String, dynamic>.from(pricing)
            : const {},
      );
    }).toList(growable: false);
  }

  String _pretty(String? v) {
    if (v == null || v.isEmpty) return '';
    return v
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  PropertyDetailsModel _merge(
    PropertyModel property,
    Map<String, dynamic> p,
    List<String> images,
    Map<String, dynamic>? pricing,
    List<UnitInfo> units,
    PropertyDetailsModel base,
  ) {
    final locality = _str(p['locality']);
    final city = _str(p['city']);
    final location = [locality, city]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    final cover = _str(p['cover_image_url']);
    final mainImage = (cover != null && cover.isNotEmpty)
        ? cover
        : (images.isNotEmpty ? images.first : property.imageUrl);

    final gallery = images.isNotEmpty ? images : base.galleryImages;

    return PropertyDetailsModel(
      id: property.id,
      title: _str(p['name']) ?? base.title,
      subtitle: _str(p['tagline'])?.isNotEmpty == true
          ? _str(p['tagline'])!
          : base.subtitle,
      location: location.isNotEmpty ? location : base.location,
      mainImageUrl: mainImage,
      galleryImages: gallery,
      galleryFullImages: gallery,
      description: _str(p['description'])?.isNotEmpty == true
          ? _str(p['description'])!
          : base.description,
      reraId: _str(p['rera_project_number']) ?? base.reraId,
      propertyType: _str(p['project_type']) ?? base.propertyType,
      mapLocation: MapLocationModel(
        latitude: _toDouble(p['latitude']) ?? base.mapLocation.latitude,
        longitude: _toDouble(p['longitude']) ?? base.mapLocation.longitude,
        mapImageUrl: base.mapLocation.mapImageUrl,
      ),
      connectivity: _connectivityFrom(p['places_nearby'], base.connectivity),
      pricing: _pricingFrom(pricing, p, base.pricing),
      units: units,
      facilities: _amenitiesFrom(p['amenities']),
      propertyInfo: _propertyInfoFrom(units, p, base.propertyInfo),
      googleMapsLink: _str(p['google_maps_link']),
      builderName: _str((p['builder'] is Map ? p['builder']['legal_name'] : null)),
      // Reused defaults (no direct API source):
      agent: base.agent,
      areaDetails: base.areaDetails,
      publicFacilities: base.publicFacilities,
      imageTags: base.imageTags,
      documents: base.documents,
      landLayoutInfo: base.landLayoutInfo,
      plotDetails: base.plotDetails,
      layoutAmenities: base.layoutAmenities,
      relatedProperties: base.relatedProperties,
    );
  }

  /// Maps the project's real `amenities` list (e.g. "Clubhouse", "Swimming
  /// pool", "Gymnasium") to facility chips. The name is shown verbatim; the
  /// icon name is a slug so known amenities get their icon and the rest fall
  /// back to a generic amenity icon. No mock fallback — real data only.
  List<FacilityModel> _amenitiesFrom(dynamic amenities) {
    if (amenities is! List) return const [];
    return amenities
        .map((e) => '$e'.trim())
        .where((e) => e.isNotEmpty)
        .map((name) => FacilityModel(name: name, iconName: _slug(name)))
        .toList(growable: false);
  }

  /// Lowercases and underscores a label, e.g. "Swimming pool" -> "swimming_pool".
  String _slug(String v) => v
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  /// Builds the "Property Info" tiles from the project's real units:
  /// sqft / BHK / bathrooms shown as ranges across the inventory, and the
  /// 4th tile repurposed to the project's available-units count (there is no
  /// safety-rank in the API). Falls back to the defaults per-field when a
  /// metric can't be derived (e.g. plots/commercial have no BHK).
  PropertyInfoModel _propertyInfoFrom(
    List<UnitInfo> units,
    Map<String, dynamic> project,
    PropertyInfoModel base,
  ) {
    if (units.isEmpty) return base;

    final sqfts = <int>[];
    final bhks = <int>[];
    final baths = <int>[];
    for (final u in units) {
      final a = u.attributes;
      final sq = _intOf(a['super_built_up_area_sqft']) ??
          _intOf(a['carpet_area_sqft']);
      if (sq != null) sqfts.add(sq);
      final bhk = _intOf(a['bhk']);
      if (bhk != null) bhks.add(bhk);
      final bath = _intOf(a['bathrooms']);
      if (bath != null) baths.add(bath);
    }

    final available = _intOf(project['available_units']);

    return PropertyInfoModel(
      sqft: sqfts.isNotEmpty ? _rangeGrouped(sqfts) : base.sqft,
      sqftLabel: sqfts.isNotEmpty ? 'Sq.ft' : base.sqftLabel,
      bedrooms: bhks.isNotEmpty ? _range(bhks) : base.bedrooms,
      bedroomsLabel: bhks.isNotEmpty ? 'Bedrooms' : base.bedroomsLabel,
      bathrooms: baths.isNotEmpty ? _range(baths) : base.bathrooms,
      bathroomsLabel: baths.isNotEmpty ? 'Bathrooms' : base.bathroomsLabel,
      safetyRank: available != null ? '$available' : base.safetyRank,
      safetyRankLabel: available != null ? 'Units Left' : base.safetyRankLabel,
    );
  }

  ConnectivityModel? _connectivityFrom(dynamic places, ConnectivityModel? base) {
    if (places is! List || places.isEmpty) return base;

    String find(List<String> keys, String fallback) {
      for (final item in places.whereType<Map>()) {
        final cat = '${item['category'] ?? ''}'.toLowerCase();
        final name = '${item['name'] ?? ''}'.toLowerCase();
        if (keys.any((k) => cat.contains(k) || name.contains(k))) {
          final dist = _str(item['distance']);
          final label = _str(item['name']) ?? '';
          return dist != null && dist.isNotEmpty ? '$label - $dist' : label;
        }
      }
      return fallback;
    }

    return ConnectivityModel(
      airport: find(['airport'], base?.airport ?? ''),
      orr: find(['orr', 'ring road', 'outer ring'], base?.orr ?? ''),
      schools: find(['school'], base?.schools ?? ''),
      hospitals: find(['hospital'], base?.hospitals ?? ''),
      techParks: find(['tech', 'it park', 'it hub'], base?.techParks ?? ''),
      metroStation: find(['metro'], base?.metroStation ?? ''),
      majorRoad: find(['road', 'highway', 'nh'], base?.majorRoad ?? ''),
    );
  }

  PricingModel? _pricingFrom(
    Map<String, dynamic>? pr,
    Map<String, dynamic> project,
    PricingModel? base,
  ) {
    if (base == null) return null;
    if (pr == null) {
      // No unit pricing — at least surface the project's "price from".
      final from = _inr(project['price_from']);
      return from.isEmpty
          ? base
          : PricingModel(
              totalAmount: from,
              amountPaid: base.amountPaid,
              balance: base.balance,
              breakdown: base.breakdown,
              grandTotal: from,
              milestones: base.milestones,
              emiCalculator: base.emiCalculator,
              relationshipManager: base.relationshipManager,
              nextPaymentAmount: base.nextPaymentAmount,
            );
    }

    final breakdown = <PriceBreakdownItem?>[
      _item('Base Price', pr['base_price']),
      _item('PLC Charges', pr['plc_charges']),
      _item('Floor Rise Charges', pr['floor_rise_charges']),
      _item('Parking Charges', pr['parking_charges']),
      _item('Club Charges', pr['club_charges']),
      _item('Maintenance Deposit', pr['maintenance_deposit']),
      _item('Corner Premium', pr['corner_premium']),
      _item('Facing Premium', pr['facing_premium']),
      _item('Other Charges', pr['other_charges']),
    ].whereType<PriceBreakdownItem>().toList();

    final total = _inr(pr['total_price']);

    return PricingModel(
      totalAmount: total.isNotEmpty ? total : base.totalAmount,
      amountPaid: base.amountPaid,
      balance: base.balance,
      breakdown: breakdown.isNotEmpty ? breakdown : base.breakdown,
      grandTotal: total.isNotEmpty ? total : base.grandTotal,
      milestones: base.milestones,
      emiCalculator: base.emiCalculator,
      relationshipManager: base.relationshipManager,
      nextPaymentAmount: _inr(pr['booking_amount']).isNotEmpty
          ? _inr(pr['booking_amount'])
          : base.nextPaymentAmount,
    );
  }

  /// Builds a breakdown row only for non-zero charges.
  PriceBreakdownItem? _item(String label, dynamic value) {
    final d = double.tryParse('${value ?? ''}');
    if (d == null || d == 0) return null;
    return PriceBreakdownItem(label: label, amount: _inr(value));
  }

  // --- helpers -------------------------------------------------------------

  String? _str(dynamic v) => v == null ? null : '$v';

  double? _toDouble(dynamic v) =>
      v == null ? null : double.tryParse('$v');

  int? _intOf(dynamic v) =>
      v == null ? null : double.tryParse('$v')?.round();

  /// "1450" -> "1450", or "[1450, 2350]" -> "2 – 4" style min–max range.
  String _range(List<int> xs) {
    final lo = xs.reduce((a, b) => a < b ? a : b);
    final hi = xs.reduce((a, b) => a > b ? a : b);
    return lo == hi ? '$lo' : '$lo – $hi';
  }

  /// Same as [_range] but with Indian digit grouping (for sqft values).
  String _rangeGrouped(List<int> xs) {
    final lo = xs.reduce((a, b) => a < b ? a : b);
    final hi = xs.reduce((a, b) => a > b ? a : b);
    return lo == hi
        ? _groupInt(lo)
        : '${_groupInt(lo)} – ${_groupInt(hi)}';
  }

  /// Indian digit grouping, e.g. 1234567 -> 12,34,567.
  String _groupInt(int n) {
    final neg = n < 0;
    final s = n.abs().toString();
    String res;
    if (s.length <= 3) {
      res = s;
    } else {
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      final grouped = rest.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+$)'),
        (m) => '${m[1]},',
      );
      res = '$grouped,$last3';
    }
    return neg ? '-$res' : res;
  }

  /// Formats a numeric value as Indian-grouped rupees, e.g. 1234567 -> ₹12,34,567.
  String _inr(dynamic v) {
    final d = double.tryParse('${v ?? ''}');
    if (d == null) return '';
    return '₹${_groupInt(d.round())}';
  }
}
