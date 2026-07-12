import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/datasources/remote/broker_auth_remote_data_source.dart';
import '../../data/datasources/remote/broker_kyc_remote_data_source.dart';
import '../../data/models/broker_model.dart';
import '../../data/models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  final BrokerAuthRemoteDataSource authDataSource;
  final BrokerKycRemoteDataSource kycDataSource;
  final LocalStorageService localStorageService;

  ProfileProvider({
    required this.authDataSource,
    required this.kycDataSource,
    required this.localStorageService,
  });

  bool _loading = false;
  bool _saving = false;
  String? _errorMessage;
  UserModel? _user;
  BrokerModel? _broker;
  bool _loadedOnce = false;

  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  BrokerModel? get broker => _broker;
  bool get loadedOnce => _loadedOnce;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await authDataSource.getMe();
      try {
        _broker = await kycDataSource.getMyBroker();
      } catch (_) {
        _broker = null; // profile can still show user info
      }
    } catch (e) {
      _errorMessage = 'Could not load your profile.';
    }
    _loading = false;
    _loadedOnce = true;
    notifyListeners();
  }

  /// Returns null on success, or an error message to display.
  Future<String?> updateProfile({
    required String fullName,
    required String mobile,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      _user = await authDataSource.updateMe(fullName: fullName, mobile: mobile);
      _saving = false;
      notifyListeners();
      return null;
    } on ServerException catch (e) {
      _saving = false;
      notifyListeners();
      return e.message;
    } catch (_) {
      _saving = false;
      notifyListeners();
      return 'Could not update profile. Please try again.';
    }
  }

  /// Logs out: best-effort server logout, then clears local session.
  Future<void> logout() async {
    final refreshToken = await localStorageService.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await authDataSource.logout(refreshToken);
      } catch (_) {
        // ignore server logout errors; clear locally regardless
      }
    }
    await localStorageService.clearAll();
    await localStorageService.setLoggedIn(isLoggedIn: false);
  }
}
