import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/datasources/remote/profile_remote_data_source.dart';
import '../../domain/entities/buyer_profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileProvider with ChangeNotifier {
  final ProfileRemoteDataSource dataSource;
  final LocalStorageService localStorageService;

  ProfileProvider({required this.dataSource, required this.localStorageService});

  ProfileStatus _status = ProfileStatus.initial;
  String? _errorMessage;
  BuyerProfile? _profile;
  bool _fetched = false;
  bool _isSaving = false;

  ProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  BuyerProfile? get profile => _profile;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isSaving => _isSaving;

  /// Loads the profile the first time it's needed. Safe to call repeatedly.
  Future<void> ensureLoaded({bool force = false}) async {
    if (_fetched && !force) return;
    _fetched = true;
    await load();
  }

  Future<void> load() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await dataSource.getMe();
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = _messageFor(e, 'Failed to load profile');
    }
    notifyListeners();
  }

  String _messageFor(Object e, String fallback) {
    if (e is ServerException) return e.message;
    if (e is NetworkException) return e.message;
    return fallback;
  }

  /// Updates the profile via PATCH /buyer/me. Returns the error message on
  /// failure, or null on success.
  Future<String?> updateProfile({
    String? fullName,
    String? address,
    String? pan,
    String? nationality,
    String? countryOfResidence,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        if (fullName != null) 'full_name': fullName,
        if (address != null) 'address': address,
        if (pan != null) 'pan': pan,
        if (nationality != null) 'nationality': nationality,
        if (countryOfResidence != null) 'country_of_residence': countryOfResidence,
      };
      _profile = await dataSource.updateMe(body);
      _status = ProfileStatus.loaded;
      return null;
    } catch (e) {
      return _messageFor(e, 'Failed to update profile');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Best-effort backend logout, then clears local session state.
  Future<void> logout() async {
    try {
      final refresh = await localStorageService.getRefreshToken();
      await dataSource.logout(refreshToken: refresh);
    } catch (_) {
      // Ignore backend errors — we still clear the local session below.
    }
    await localStorageService.setLoggedIn(isLoggedIn: false);
    _profile = null;
    _fetched = false;
    _status = ProfileStatus.initial;
    notifyListeners();
  }
}
