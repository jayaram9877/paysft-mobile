import 'package:flutter/material.dart';

import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/saved_units_remote_data_source.dart';
import '../../domain/entities/favorite_unit.dart';

/// Holds the buyer's saved units ("favorites") and drives the save/remove
/// calls against /buyer/saved-units. Registered app-wide so unit cards and the
/// Favorites screen share one source of truth.
class SavedUnitsProvider extends ChangeNotifier {
  final SavedUnitsRemoteDataSource dataSource;

  SavedUnitsProvider({required this.dataSource});

  bool _loaded = false;
  bool _loading = false;
  bool get isLoading => _loading;

  /// Enriched saved rows for the Favorites "Saved" tab.
  List<FavoriteUnit> _saved = [];
  List<FavoriteUnit> get saved => _saved;

  /// Fast lookup of saved unit_ids for the card toggle state.
  final Set<String> _savedIds = {};

  /// unit_ids with an in-flight save/remove request.
  final Set<String> _busy = {};

  bool isSaved(String unitId) => _savedIds.contains(unitId);
  bool isBusy(String unitId) => _busy.contains(unitId);

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      final units = await dataSource.getSavedUnits();
      _saved = units;
      _savedIds
        ..clear()
        ..addAll(units.map((u) => u.unitId));
      _loaded = true;
    } catch (_) {
      // Leave unloaded so it retries on the next appearance.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Toggles saved state for a unit. Returns a snackbar message, or null if the
  /// request was ignored (busy / empty id).
  Future<String?> toggleSaved(String unitId) async {
    if (unitId.isEmpty || _busy.contains(unitId)) return null;
    _busy.add(unitId);
    notifyListeners();

    String message;
    try {
      if (_savedIds.contains(unitId)) {
        await dataSource.removeSavedUnit(unitId);
        _savedIds.remove(unitId);
        _saved =
            _saved.where((u) => u.unitId != unitId).toList(growable: false);
        message = 'Removed from favorites';
      } else {
        await dataSource.saveUnit(unitId);
        _savedIds.add(unitId);
        // The rich card appears after the next reload of the Saved tab.
        message = 'Saved to favorites';
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
