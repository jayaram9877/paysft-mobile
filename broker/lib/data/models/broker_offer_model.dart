/// Mirrors the API `BrokerOfferResponse` — a pending lead offer routed to the
/// broker. Carries the project/unit context but NO buyer PII until accepted.
class BrokerOfferModel {
  final String leadId;
  final String projectId;
  final String unitId;
  final String projectName;
  final String projectLocality;
  final String projectCity;
  final String unitNumber;
  final String? unitTitle;
  final String? unitType;
  final DateTime? offeredAt;
  final DateTime? expiresAt;

  BrokerOfferModel({
    required this.leadId,
    required this.projectId,
    required this.unitId,
    this.projectName = '',
    this.projectLocality = '',
    this.projectCity = '',
    this.unitNumber = '',
    this.unitTitle,
    this.unitType,
    this.offeredAt,
    this.expiresAt,
  });

  static String? _s(dynamic v) => v?.toString();

  factory BrokerOfferModel.fromJson(Map<String, dynamic> json) {
    return BrokerOfferModel(
      leadId: _s(json['lead_id']) ?? '',
      projectId: _s(json['project_id']) ?? '',
      unitId: _s(json['unit_id']) ?? '',
      projectName: _s(json['project_name']) ?? '',
      projectLocality: _s(json['project_locality']) ?? '',
      projectCity: _s(json['project_city']) ?? '',
      unitNumber: _s(json['unit_number']) ?? '',
      unitTitle: _s(json['unit_title']),
      unitType: _s(json['unit_type']),
      offeredAt: DateTime.tryParse(_s(json['offered_at']) ?? ''),
      expiresAt: DateTime.tryParse(_s(json['expires_at']) ?? ''),
    );
  }

  String get location {
    final parts =
        [projectLocality, projectCity].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }
}
