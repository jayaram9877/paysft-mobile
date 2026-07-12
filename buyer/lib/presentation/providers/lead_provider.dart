import 'package:flutter/material.dart';

import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/lead_remote_data_source.dart';
import '../../data/datasources/remote/favorite_unit_mapper.dart';
import '../../domain/entities/favorite_unit.dart';

/// Holds the buyer's "I'm Interested" state per unit and drives the
/// express/withdraw calls. Registered app-wide so every unit card and the
/// unit details page share one source of truth.
class LeadProvider extends ChangeNotifier {
  final LeadRemoteDataSource dataSource;

  LeadProvider({required this.dataSource});

  bool _loaded = false;
  bool _loading = false;
  bool get isLoading => _loading;

  /// unit_id -> lead_id for units the buyer is currently interested in.
  final Map<String, String> _interested = {};

  /// Enriched interest rows for the Favorites "Interested" tab (newest first).
  List<FavoriteUnit> _interests = [];
  List<FavoriteUnit> get interests => _interests;

  /// unit_ids with an in-flight express/withdraw request.
  final Set<String> _busy = {};

  bool isInterested(String unitId) => _interested.containsKey(unitId);
  bool isBusy(String unitId) => _busy.contains(unitId);

  /// True when the buyer has expressed interest in at least one of [unitIds].
  bool hasInterestInAnyUnit(Iterable<String> unitIds) =>
      unitIds.any((id) => id.isNotEmpty && _interested.containsKey(id));

  /// Loads the buyer's interests once (call when a units view appears).
  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      final rows = await dataSource.getActiveLeadRows();
      _interested
        ..clear()
        ..addEntries(rows
            .where((r) => '${r['unit_id'] ?? ''}'.isNotEmpty &&
                '${r['id'] ?? ''}'.isNotEmpty)
            .map((r) => MapEntry('${r['unit_id']}', '${r['id']}')));
      _interests = rows.map(FavoriteUnitMapper.fromLead).toList(growable: false);
      _loaded = true;
    } catch (_) {
      // Leave unloaded so it retries on the next appearance.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Registers interest without toggling off. Used on property/unit details.
  Future<String?> expressInterest(String unitId) async {
    if (unitId.isEmpty || _busy.contains(unitId) || _interested.containsKey(unitId)) {
      return null;
    }
    _busy.add(unitId);
    notifyListeners();

    String message;
    try {
      final leadId = await dataSource.expressInterest(unitId);
      _interested[unitId] = leadId;
      await reload();
      message = "Interest sent — an advisor will reach out to you";
    } on ServerException catch (e) {
      message = e.message;
    } on NetworkException catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Something went wrong. Please try again.';
    } finally {
      _busy.remove(unitId);
      notifyListeners();
    }
    return message;
  }

  /// Toggles interest for a unit. Returns a user-facing message to surface in a
  /// snackbar (success or error), or null if the request was ignored (busy).
  Future<String?> toggleInterest(String unitId) async {
    if (unitId.isEmpty || _busy.contains(unitId)) return null;
    _busy.add(unitId);
    notifyListeners();

    String message;
    try {
      if (_interested.containsKey(unitId)) {
        await dataSource.cancelInterest(_interested[unitId]!);
        _interested.remove(unitId);
        _interests =
            _interests.where((u) => u.unitId != unitId).toList(growable: false);
        message = 'Interest dropped';
      } else {
        final leadId = await dataSource.expressInterest(unitId);
        _interested[unitId] = leadId;
        message = "Interest sent — an advisor will reach out to you";
      }
    } on ServerException catch (e) {
      message = e.message;
    } on NetworkException catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Something went wrong. Please try again.';
    } finally {
      _busy.remove(unitId);
      notifyListeners();
    }
    return message;
  }
}
