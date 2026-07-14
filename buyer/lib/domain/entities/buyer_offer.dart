/// Summary row from GET /buyer/sales (BuyerSaleSummary).
class BuyerOfferSummary {
  final String saleId;
  final String status;
  final String projectName;
  final String unitLabel;
  final String totalCost;

  /// Raw numeric total cost (INR) for aggregation; 0 when unknown.
  final double totalCostValue;

  const BuyerOfferSummary({
    required this.saleId,
    required this.status,
    required this.projectName,
    required this.unitLabel,
    required this.totalCost,
    this.totalCostValue = 0,
  });

  bool get canRespond => status == 'sent' || status == 'viewed';
}

/// Full sale from GET /buyer/sales/{id} and mutation responses.
class BuyerOfferDetail {
  final String saleId;
  final String status;
  final String projectId;
  final String projectName;
  final String? projectLocation;
  final String? projectRera;
  final String projectType;
  final String projectSubtype;
  final String unitNumber;
  final String? unitTitle;
  final String builderName;
  final String totalCost;

  /// Raw numeric total cost (INR) for aggregation; 0 when unknown.
  final double totalCostValue;
  final Map<String, dynamic> costBreakdown;
  final List<Map<String, dynamic>> milestones;
  final Map<String, dynamic>? escrow;
  final Map<String, dynamic>? relationshipManager;
  final DateTime? sentAt;
  final DateTime? viewedAt;
  final DateTime? acceptedAt;
  final DateTime? declinedAt;

  const BuyerOfferDetail({
    required this.saleId,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.projectLocation,
    required this.projectRera,
    required this.projectType,
    required this.projectSubtype,
    required this.unitNumber,
    required this.unitTitle,
    required this.builderName,
    required this.totalCost,
    this.totalCostValue = 0,
    required this.costBreakdown,
    required this.milestones,
    this.escrow,
    this.relationshipManager,
    this.sentAt,
    this.viewedAt,
    this.acceptedAt,
    this.declinedAt,
  });

  bool get canRespond => status == 'sent' || status == 'viewed';

  String get unitLabel {
    if (unitTitle != null && unitTitle!.isNotEmpty) return unitTitle!;
    if (unitNumber.isNotEmpty) return unitNumber;
    return 'Unit';
  }
}

/// Preview payload from GET /buyer/sales/{id}/preview.
class BuyerOfferPreview {
  final String saleId;
  final String status;
  final String projectName;
  final String unitNumber;
  final String? unitTitle;
  final String builderName;
  final String? buyerName;
  final String totalCost;
  final Map<String, dynamic> costBreakdown;
  final List<Map<String, dynamic>> milestones;

  const BuyerOfferPreview({
    required this.saleId,
    required this.status,
    required this.projectName,
    required this.unitNumber,
    required this.unitTitle,
    required this.builderName,
    required this.buyerName,
    required this.totalCost,
    required this.costBreakdown,
    required this.milestones,
  });
}
