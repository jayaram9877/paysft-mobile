import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/broker_visits_remote_data_source.dart';
import '../../data/models/broker_visit_model.dart';

/// Drives the client detail screen: loads the visits for one lead/client and
/// schedules / reschedules / cancels them.
class ClientScheduleProvider with ChangeNotifier {
  final BrokerVisitsRemoteDataSource visitsDataSource;

  ClientScheduleProvider({required this.visitsDataSource});

  String _leadId = '';
  bool _loading = false;
  bool _busy = false;
  String? _errorMessage;
  List<BrokerVisitModel> _visits = [];

  bool get isLoading => _loading;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;

  /// Active (non-cancelled) visits for this client, soonest first.
  List<BrokerVisitModel> get visits {
    final list = _visits.where((v) => !v.isCancelled).toList()
      ..sort((a, b) => (a.scheduledFor ?? DateTime(2100))
          .compareTo(b.scheduledFor ?? DateTime(2100)));
    return list;
  }

  bool get hasScheduled => _visits.any((v) => v.isScheduled);

  Future<void> load(String leadId) async {
    _leadId = leadId;
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final all = await visitsDataSource.listVisits();
      _visits = all.where((v) => v.leadId == leadId).toList();
    } catch (_) {
      _errorMessage = 'Could not load visits.';
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> schedule(DateTime when, {String? notes}) async {
    return _run(() async {
      final v = await visitsDataSource.scheduleVisit(
        leadId: _leadId,
        scheduledFor: when,
        notes: notes,
      );
      _visits = [..._visits, v];
    }, 'Could not schedule the visit.');
  }

  Future<String?> reschedule(String visitId, DateTime when) async {
    return _run(() async {
      final v = await visitsDataSource.rescheduleVisit(
        visitId: visitId,
        scheduledFor: when,
      );
      _visits = _visits.map((x) => x.id == visitId ? v : x).toList();
    }, 'Could not reschedule the visit.');
  }

  Future<String?> cancel(String visitId) async {
    return _run(() async {
      await visitsDataSource.cancelVisit(visitId);
      _visits = _visits.map((x) {
        if (x.id != visitId) return x;
        return BrokerVisitModel(
          id: x.id,
          leadId: x.leadId,
          projectId: x.projectId,
          unitId: x.unitId,
          scheduledFor: x.scheduledFor,
          status: 'cancelled',
          notes: x.notes,
          cancelledAt: x.cancelledAt,
          completedAt: x.completedAt,
        );
      }).toList();
    }, 'Could not cancel the visit.');
  }

  Future<String?> _run(Future<void> Function() action, String fallback) async {
    if (_busy) return null;
    _busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } on ServerException catch (e) {
      return e.message;
    } catch (_) {
      return fallback;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
