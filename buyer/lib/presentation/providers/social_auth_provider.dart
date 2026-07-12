import 'package:flutter/foundation.dart';
import '../../core/services/social_auth_service.dart';
import '../../core/services/local_storage_service.dart';

enum SocialAuthStatus { idle, loading, success, error }
enum SocialProviderType { google, apple }

class SocialAuthProvider extends ChangeNotifier {
  final SocialAuthService socialAuthService;
  final LocalStorageService? localStorageService;

  SocialAuthProvider({
    required this.socialAuthService,
    this.localStorageService,
  });

  SocialAuthStatus _status = SocialAuthStatus.idle;
  SocialProviderType? _activeProvider;
  String? _errorMessage;
  String? _email;
  String? _displayName;

  SocialAuthStatus get status => _status;
  SocialProviderType? get activeProvider => _activeProvider;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  String? get displayName => _displayName;
  bool get isLoggedIn => _status == SocialAuthStatus.success;

  Future<bool> loginWithGoogle() async {
    return _login(() => socialAuthService.signInWithGoogle(), SocialProviderType.google);
  }

  Future<bool> loginWithApple() async {
    return _login(() => socialAuthService.signInWithApple(), SocialProviderType.apple);
  }

  Future<bool> _login(
    Future<SocialLoginResult> Function() loginAction,
    SocialProviderType provider,
  ) async {
    _status = SocialAuthStatus.loading;
    _errorMessage = null;
    _activeProvider = provider;
    notifyListeners();

    final result = await loginAction();

    if (result.success) {
      _status = SocialAuthStatus.success;
      _email = result.email;
      _displayName = result.displayName;
      _activeProvider = null;
      // Save login state
      localStorageService?.setLoggedIn(
        isLoggedIn: true,
        authType: 'social',
        socialProvider: provider == SocialProviderType.google ? 'google' : 'apple',
      );
      notifyListeners();
      return true;
    }

    if (result.cancelled) {
      _status = SocialAuthStatus.idle;
      _activeProvider = null;
      notifyListeners();
      return false;
    }

    _status = SocialAuthStatus.error;
    _errorMessage = result.errorMessage ?? 'Something went wrong';
    _activeProvider = null;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await socialAuthService.signOutGoogle();
    _status = SocialAuthStatus.idle;
    _email = null;
    _displayName = null;
    _errorMessage = null;
    _activeProvider = null;
    // Clear login state from storage
    localStorageService?.setLoggedIn(isLoggedIn: false);
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    if (localStorageService == null) return;
    
    final isLoggedIn = await localStorageService!.isLoggedIn();
    final authType = await localStorageService!.getAuthType();
    
    if (isLoggedIn && authType == 'social') {
      _status = SocialAuthStatus.success;
      final socialProvider = await localStorageService!.getSocialProvider();
      // Note: We can't restore email/displayName from storage without storing them
      // This is a limitation - you may want to store them if needed
      notifyListeners();
    }
  }
}

