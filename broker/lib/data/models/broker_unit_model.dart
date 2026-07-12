/// Mirrors the API `UnitPricingResponse` — the full price breakup for a unit.
class BrokerUnitPricingModel {
  final String? basePrice;
  final String? plcCharges;
  final String? floorRiseCharges;
  final String? parkingCharges;
  final String? clubCharges;
  final String? maintenanceDeposit;
  final String? otherCharges;
  final String? bookingAmount;
  final String? cornerPremium;
  final String? facingPremium;
  final String? totalPrice;
  final String? priceNotes;

  BrokerUnitPricingModel({
    this.basePrice,
    this.plcCharges,
    this.floorRiseCharges,
    this.parkingCharges,
    this.clubCharges,
    this.maintenanceDeposit,
    this.otherCharges,
    this.bookingAmount,
    this.cornerPremium,
    this.facingPremium,
    this.totalPrice,
    this.priceNotes,
  });

  factory BrokerUnitPricingModel.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    return BrokerUnitPricingModel(
      basePrice: s('base_price'),
      plcCharges: s('plc_charges'),
      floorRiseCharges: s('floor_rise_charges'),
      parkingCharges: s('parking_charges'),
      clubCharges: s('club_charges'),
      maintenanceDeposit: s('maintenance_deposit'),
      otherCharges: s('other_charges'),
      bookingAmount: s('booking_amount'),
      cornerPremium: s('corner_premium'),
      facingPremium: s('facing_premium'),
      totalPrice: s('total_price'),
      priceNotes: s('price_notes'),
    );
  }
}

/// Mirrors the API `UnitResponse` — an individual unit within a project.
class BrokerUnitModel {
  final String id;
  final String projectId;
  final String unitType; // flat | plot | villa | office | retail | warehouse
  final String unitNumber;
  final String? propertyTitle;
  final String inventoryStatus; // available | blocked | sold_* | held | off_market
  final String? statusReason;
  final Map<String, dynamic> attributes;
  final BrokerUnitPricingModel? pricing;

  BrokerUnitModel({
    required this.id,
    required this.projectId,
    required this.unitType,
    required this.unitNumber,
    this.propertyTitle,
    required this.inventoryStatus,
    this.statusReason,
    this.attributes = const {},
    this.pricing,
  });

  bool get isAvailable => inventoryStatus == 'available';

  String? get totalPrice => pricing?.totalPrice;
  String? get basePrice => pricing?.basePrice;
  String? get bookingAmount => pricing?.bookingAmount;

  static String? _s(dynamic v) => v?.toString();

  factory BrokerUnitModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'];
    final attrs = json['attributes'];
    return BrokerUnitModel(
      id: _s(json['id']) ?? '',
      projectId: _s(json['project_id']) ?? '',
      unitType: _s(json['unit_type']) ?? '',
      unitNumber: _s(json['unit_number']) ?? '',
      propertyTitle: _s(json['property_title']),
      inventoryStatus: _s(json['inventory_status']) ?? '',
      statusReason: _s(json['status_reason']),
      attributes:
          attrs is Map ? Map<String, dynamic>.from(attrs) : const {},
      pricing: pricing is Map
          ? BrokerUnitPricingModel.fromJson(Map<String, dynamic>.from(pricing))
          : null,
    );
  }
}
