import 'package:flutter/material.dart';

import '../../data/datasources/remote/visits_remote_data_source.dart';
import '../../domain/entities/visit_meeting.dart';

/// Holds the buyer's site visits ("meetings"). App-wide so the Home upcoming
/// card and the Chat "Meetings" tab share one source of truth.
class VisitsProvider extends ChangeNotifier {
  final VisitsRemoteDataSource dataSource;

  VisitsProvider({required this.dataSource});

  bool _loaded = false;
  bool _loading = false;
  bool get isLoading => _loading;

  List<VisitMeeting> _all = [];

  /// Upcoming first (soonest → latest), then everything else (newest → oldest).
  List<VisitMeeting> get visits {
    final now = DateTime.now();
    final upcoming = _all.where((v) => v.isUpcomingAt(now)).toList()
      ..sort((a, b) => a.scheduledFor!.compareTo(b.scheduledFor!));
    final rest = _all.where((v) => !v.isUpcomingAt(now)).toList()
      ..sort((a, b) {
        final ad = a.scheduledFor;
        final bd = b.scheduledFor;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    return [...upcoming, ...rest];
  }

  List<VisitMeeting> get upcoming {
    final now = DateTime.now();
    return _all.where((v) => v.isUpcomingAt(now)).toList()
      ..sort((a, b) => a.scheduledFor!.compareTo(b.scheduledFor!));
  }

  /// The soonest upcoming visit, or null.
  VisitMeeting? get nextUpcoming {
    final up = upcoming;
    return up.isEmpty ? null : up.first;
  }

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      _all = await dataSource.getVisits();
      _loaded = true;
    } catch (_) {
      // Leave unloaded so it retries on the next appearance.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
