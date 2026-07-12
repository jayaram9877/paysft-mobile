/// Mirrors the API `SiteVisitResponse` — a scheduled site visit.
/// Note: the API exposes no visitor PII or property details here, only ids +
/// the scheduled time and status.
class BrokerVisitModel {
  final String id;
  final String leadId;
  final String projectId;
  final String unitId;
  final DateTime? scheduledFor;
  final String status; // scheduled | completed | cancelled | no_show
  final String? notes;
  final DateTime? cancelledAt;
  final DateTime? completedAt;

  BrokerVisitModel({
    required this.id,
    required this.leadId,
    required this.projectId,
    required this.unitId,
    required this.scheduledFor,
    required this.status,
    this.notes,
    this.cancelledAt,
    this.completedAt,
  });

  static String? _s(dynamic v) => v?.toString();

  factory BrokerVisitModel.fromJson(Map<String, dynamic> json) {
    return BrokerVisitModel(
      id: _s(json['id']) ?? '',
      leadId: _s(json['lead_id']) ?? '',
      projectId: _s(json['project_id']) ?? '',
      unitId: _s(json['unit_id']) ?? '',
      scheduledFor: DateTime.tryParse(_s(json['scheduled_for']) ?? ''),
      status: _s(json['status']) ?? 'scheduled',
      notes: _s(json['notes']),
      cancelledAt: DateTime.tryParse(_s(json['cancelled_at']) ?? ''),
      completedAt: DateTime.tryParse(_s(json['completed_at']) ?? ''),
    );
  }

  bool get isScheduled => status == 'scheduled';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isNoShow => status == 'no_show';

  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No show';
      default:
        return 'Scheduled';
    }
  }
}
