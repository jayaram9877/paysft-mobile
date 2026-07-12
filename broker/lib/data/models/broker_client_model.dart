/// Mirrors the API `AcceptedLeadResponse` — a lead the broker has accepted
/// (i.e. a client). Buyer PII (name) is revealed once accepted.
class BrokerClientModel {
  final String leadId;
  final String projectId;
  final String unitId;
  final String buyerId;
  final String buyerFullName;
  final String projectName;
  final String projectLocality;
  final String projectCity;
  final String unitNumber;
  final String? unitTitle;
  final String? unitType;
  final String? notes;
  final DateTime? lockedAt;

  BrokerClientModel({
    required this.leadId,
    required this.projectId,
    required this.unitId,
    required this.buyerId,
    required this.buyerFullName,
    required this.projectName,
    required this.projectLocality,
    required this.projectCity,
    required this.unitNumber,
    this.unitTitle,
    this.unitType,
    this.notes,
    this.lockedAt,
  });

  static String? _s(dynamic v) => v?.toString();

  factory BrokerClientModel.fromJson(Map<String, dynamic> json) {
    return BrokerClientModel(
      leadId: _s(json['lead_id']) ?? '',
      projectId: _s(json['project_id']) ?? '',
      unitId: _s(json['unit_id']) ?? '',
      buyerId: _s(json['buyer_id']) ?? '',
      buyerFullName: _s(json['buyer_full_name']) ?? 'Buyer',
      projectName: _s(json['project_name']) ?? 'Project',
      projectLocality: _s(json['project_locality']) ?? '',
      projectCity: _s(json['project_city']) ?? '',
      unitNumber: _s(json['unit_number']) ?? '',
      unitTitle: _s(json['unit_title']),
      unitType: _s(json['unit_type']),
      notes: _s(json['notes']),
      lockedAt: DateTime.tryParse(_s(json['locked_at']) ?? ''),
    );
  }

  String get location {
    final parts =
        [projectLocality, projectCity].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get unitLabel {
    final t = (unitTitle?.isNotEmpty == true) ? unitTitle! : unitType ?? 'Unit';
    return unitNumber.isEmpty ? t : '$t · $unitNumber';
  }

  String get initials {
    final parts =
        buyerFullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
