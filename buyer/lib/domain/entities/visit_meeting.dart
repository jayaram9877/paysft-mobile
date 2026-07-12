/// A scheduled site visit ("meeting") for the buyer, from GET /buyer/visits.
class VisitMeeting {
  final String id;
  final String leadId; // used to look up the assigned broker
  final String projectId; // used to open the property details page
  final String unitId; // used to match against a specific unit card
  final DateTime? scheduledFor; // local time
  final String status; // scheduled / completed / cancelled / no_show
  final String? notes;
  final String projectName;
  final String unitTitle;
  final String unitNumber;
  final String? brokerName; // filled in via a best-effort lead-detail lookup

  const VisitMeeting({
    required this.id,
    required this.leadId,
    required this.projectId,
    required this.unitId,
    required this.scheduledFor,
    required this.status,
    required this.notes,
    required this.projectName,
    required this.unitTitle,
    required this.unitNumber,
    this.brokerName,
  });

  VisitMeeting copyWith({String? brokerName}) => VisitMeeting(
        id: id,
        leadId: leadId,
        projectId: projectId,
        unitId: unitId,
        scheduledFor: scheduledFor,
        status: status,
        notes: notes,
        projectName: projectName,
        unitTitle: unitTitle,
        unitNumber: unitNumber,
        brokerName: brokerName ?? this.brokerName,
      );

  /// Still to happen: scheduled and in the future.
  bool isUpcomingAt(DateTime now) =>
      status == 'scheduled' &&
      scheduledFor != null &&
      scheduledFor!.isAfter(now);

  /// Best single-line label for the property this visit is for.
  String get propertyLabel {
    if (unitTitle.isNotEmpty) return unitTitle;
    if (projectName.isNotEmpty && unitNumber.isNotEmpty) {
      return '$projectName · $unitNumber';
    }
    return projectName;
  }
}
