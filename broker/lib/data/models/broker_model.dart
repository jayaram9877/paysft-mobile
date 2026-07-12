/// Minimal mirror of the API `BrokerResponse` schema.
class BrokerModel {
  final String id;
  final String status; // pending | active | blocked
  final String? legalName;
  final String? entityType;
  final String? pan;
  final String? reraAgentNumber;
  final String? reraAgentState;
  final String? registeredAddress;
  final String? bankAccountNumber;
  final String? bankAccountHolderName;
  final String? bankIfsc;
  final String? bankName;

  BrokerModel({
    required this.id,
    required this.status,
    this.legalName,
    this.entityType,
    this.pan,
    this.reraAgentNumber,
    this.reraAgentState,
    this.registeredAddress,
    this.bankAccountNumber,
    this.bankAccountHolderName,
    this.bankIfsc,
    this.bankName,
  });

  factory BrokerModel.fromJson(Map<String, dynamic> json) {
    return BrokerModel(
      id: json['id'] as String,
      status: json['status'] as String,
      legalName: json['legal_name'] as String?,
      entityType: json['entity_type'] as String?,
      pan: json['pan'] as String?,
      reraAgentNumber: json['rera_agent_number'] as String?,
      reraAgentState: json['rera_agent_state'] as String?,
      registeredAddress: json['registered_address'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankAccountHolderName: json['bank_account_holder_name'] as String?,
      bankIfsc: json['bank_ifsc'] as String?,
      bankName: json['bank_name'] as String?,
    );
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isBlocked => status == 'blocked';
  bool get hasBankDetails => (bankAccountNumber ?? '').isNotEmpty;
}
