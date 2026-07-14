/// Mirrors the API `BrokerAssignmentResponse` — a broker's alignment to a
/// project. Only `aligned` assignments participate in lead routing.
class BrokerAssignmentModel {
  final String id;
  final String brokerId;
  final String projectId;
  final String status; // aligned | paused | revoked | pending | rejected
  final DateTime? alignedAt;
  final DateTime? revokedAt;

  BrokerAssignmentModel({
    required this.id,
    required this.brokerId,
    required this.projectId,
    required this.status,
    this.alignedAt,
    this.revokedAt,
  });

  bool get isAligned => status == 'aligned';

  factory BrokerAssignmentModel.fromJson(Map<String, dynamic> json) {
    return BrokerAssignmentModel(
      id: json['id'] as String,
      brokerId: (json['broker_id'] as String?) ?? '',
      projectId: (json['project_id'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'aligned',
      alignedAt: DateTime.tryParse((json['aligned_at'] as String?) ?? ''),
      revokedAt: DateTime.tryParse((json['revoked_at'] as String?) ?? ''),
    );
  }
}
