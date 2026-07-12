import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/broker_visits_remote_data_source.dart';
import '../../data/datasources/remote/broker_projects_remote_data_source.dart';
import '../../data/models/broker_visit_model.dart';
import '../../data/models/broker_project_model.dart';

/// Loads the broker's scheduled site visits and resolves the project for each,
/// driving the Schedule calendar.
class ScheduleProvider with ChangeNotifier {
  final BrokerVisitsRemoteDataSource visitsDataSource;
  final BrokerProjectsRemoteDataSource projectsDataSource;

  ScheduleProvider({
    required this.visitsDataSource,
    required this.projectsDataSource,
  });

  bool _loading = false;
  bool _loadedOnce = false;
  String? _errorMessage;
  List<BrokerVisitModel> _visits = [];
  final Map<String, BrokerProjectModel> _projects = {};
  final Set<String> _cancellingIds = {};

  bool get isLoading => _loading;
  bool get loadedOnce => _loadedOnce;
  String? get errorMessage => _errorMessage;
  bool isCancelling(String visitId) => _cancellingIds.contains(visitId);

  static DateTime _dayKey(DateTime d) {
    final l = d.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  /// Active (non-cancelled) visits on a given calendar day, sorted by time.
  List<BrokerVisitModel> visitsOn(DateTime day) {
    final key = _dayKey(day);
    final list = _visits
        .where((v) =>
            !v.isCancelled &&
            v.scheduledFor != null &&
            _dayKey(v.scheduledFor!) == key)
        .toList()
      ..sort((a, b) => a.scheduledFor!.compareTo(b.scheduledFor!));
    return list;
  }

  /// Days (midnight, local) that have at least one active visit — for dots.
  Set<DateTime> get datesWithVisits => _visits
      .where((v) => !v.isCancelled && v.scheduledFor != null)
      .map((v) => _dayKey(v.scheduledFor!))
      .toSet();

  bool hasVisitsOn(DateTime day) => datesWithVisits.contains(_dayKey(day));

  BrokerProjectModel? projectFor(String projectId) => _projects[projectId];

  String projectNameFor(String projectId) =>
      _projects[projectId]?.name ?? 'Site visit';

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        visitsDataSource.listVisits(),
        projectsDataSource.listProjects(),
      ]);
      _visits = results[0] as List<BrokerVisitModel>;
      final projects = results[1] as List<BrokerProjectModel>;
      _projects
        ..clear()
        ..addEntries(projects.map((p) => MapEntry(p.id, p)));
    } catch (e) {
      _errorMessage = 'Could not load your schedule.';
    }
    _loading = false;
    _loadedOnce = true;
    notifyListeners();
  }

  /// Cancels a visit. Returns null on success or an error message.
  Future<String?> cancelVisit(String visitId) async {
    if (isCancelling(visitId)) return null;
    _cancellingIds.add(visitId);
    notifyListeners();
    try {
      await visitsDataSource.cancelVisit(visitId);
      // Reflect locally: mark the visit cancelled so it drops off the calendar.
      _visits = _visits.map((v) {
        if (v.id != visitId) return v;
        return BrokerVisitModel(
          id: v.id,
          leadId: v.leadId,
          projectId: v.projectId,
          unitId: v.unitId,
          scheduledFor: v.scheduledFor,
          status: 'cancelled',
          notes: v.notes,
          cancelledAt: v.cancelledAt,
          completedAt: v.completedAt,
        );
      }).toList();
      return null;
    } on ServerException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not cancel this visit. Please try again.';
    } finally {
      _cancellingIds.remove(visitId);
      notifyListeners();
    }
  }
}
