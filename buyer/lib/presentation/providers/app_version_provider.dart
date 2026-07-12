import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/app_version_check.dart';
import '../../domain/usecases/verify_app_version.dart';

enum AppVersionStatus { initial, loading, checked, error }

class AppVersionProvider with ChangeNotifier {
  final VerifyAppVersion verifyAppVersion;

  AppVersionProvider({required this.verifyAppVersion});

  AppVersionStatus _status = AppVersionStatus.initial;
  String? _errorMessage;
  String? _currentVersion;
  AppVersionCheck _versionCheck = const AppVersionCheck(
    isUpdateRequired: false,
  );

  AppVersionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get currentVersion => _currentVersion;
  AppVersionCheck get versionCheck => _versionCheck;
  bool get isUpdateRequired => _versionCheck.isUpdateRequired;

  Future<void> verifyOnAppLaunch() async {
    _status = AppVersionStatus.loading;
    _errorMessage = null;

    try {
      _currentVersion = await _resolveAppVersion();

      final result = await verifyAppVersion(
        VerifyAppVersionParams(_currentVersion!),
      );
      result.fold(
        (failure) {
          _status = AppVersionStatus.error;
          _errorMessage = _mapFailureToMessage(failure);
        },
        (check) {
          _status = AppVersionStatus.checked;
          _versionCheck = check;
        },
      );
    } catch (_) {
      _status = AppVersionStatus.error;
      _errorMessage = 'Failed to verify app version';
    }

    notifyListeners();
  }

  Future<String> _resolveAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.trim();
      if (version.isNotEmpty) return version;
    } catch (_) {
      // Fallback below keeps startup API call deterministic.
    }
    return '1.0.0';
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      default:
        return 'Unexpected error: ${failure.message}';
    }
  }
}
