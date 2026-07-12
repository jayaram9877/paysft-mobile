import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/datasources/remote/broker_auth_remote_data_source.dart';

enum BrokerAuthStatus { initial, loading, otpSent, success, error }

/// Outcome of trying to restore a persisted session.
enum SessionRestore { ok, invalid, network, none }

/// Drives the broker signup → verify-email → login flow against the real
/// PaySFT API. All fields come from real user input — nothing is hardcoded.
class BrokerAuthProvider with ChangeNotifier {
  final BrokerAuthRemoteDataSource remoteDataSource;
  final LocalStorageService? localStorageService;

  BrokerAuthProvider({
    required this.remoteDataSource,
    this.localStorageService,
  });

  BrokerAuthStatus _status = BrokerAuthStatus.initial;
  String? _errorMessage;
  String? _mobile; // full +91XXXXXXXXXX, for display on the OTP screen
  String? _email; // the email used for the current signup
  String? _password; // the password used for the current signup

  BrokerAuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get mobile => _mobile;
  String get email => _email ?? '';

  /// True while a network call is in flight (used to drive loaders in the UI).
  bool get isLoading => _status == BrokerAuthStatus.loading;

  /// Validation rule for an Indian mobile: 10 digits starting 6-9.
  /// [tenDigits] is the number without the +91 prefix.
  static bool isValidMobile(String tenDigits) =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(tenDigits);

  /// Basic email format validation.
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email.trim());

  /// Signup password rule: at least 8 characters (matches the API).
  static bool isValidPassword(String password) => password.length >= 8;

  /// Clears any error so stale messages don't persist across screen visits.
  void clearError() {
    if (_status == BrokerAuthStatus.error) _status = BrokerAuthStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  bool _looksLikeAlreadyExists(String message) {
    final m = message.toLowerCase();
    return m.contains('already') || m.contains('exist') || m.contains('conflict');
  }

  bool _looksLikeAlreadyVerified(String message) {
    final m = message.toLowerCase();
    return m.contains('already') && m.contains('verif');
  }

  /// Step 2 + 3: verify the email OTP and SMS OTP together, then log in to
  /// obtain a TokenPair.
  Future<bool> verifyAndRegister(String emailOtp, String mobileOtp) async {
    final mail = _email;
    final pass = _password;
    if (mail == null || pass == null) {
      return _fail('Session expired. Please sign up again.');
    }
    _status = BrokerAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      try {
        await remoteDataSource.verifyContact(
          email: mail,
          emailOtp: emailOtp,
          mobileOtp: mobileOtp,
        );
      } on ServerException catch (e) {
        // If both contacts are already verified from a previous run, proceed to
        // login; otherwise surface the error (wrong/expired OTP).
        if (!_looksLikeAlreadyVerified(e.message)) rethrow;
      }

      final tokens = await remoteDataSource.login(
        email: mail,
        password: pass,
      );

      await localStorageService?.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await localStorageService?.setLoggedIn(
        isLoggedIn: true,
        phoneNumber: _mobile,
        authType: 'email',
      );

      _status = BrokerAuthStatus.success;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      _status = BrokerAuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = BrokerAuthStatus.error;
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Email signup with user-entered details against POST /auth/broker/signup.
  /// On success an OTP is emailed; the OTP screen then calls
  /// [verifyAndRegister] which uses the stored email + password.
  /// [tenDigitMobile] is the 10 digits after the +91 country code.
  Future<bool> signupWithEmail({
    required String fullName,
    required String email,
    required String tenDigitMobile,
    required String password,
  }) async {
    if (fullName.trim().isEmpty) {
      return _fail('Please enter your full name');
    }
    if (!isValidEmail(email)) {
      return _fail('Please enter a valid email address');
    }
    if (!isValidMobile(tenDigitMobile)) {
      return _fail('Please enter a valid 10-digit mobile number');
    }
    if (!isValidPassword(password)) {
      return _fail('Password must be at least 8 characters');
    }

    _email = email.trim();
    _password = password;
    _mobile = '+91$tenDigitMobile';
    _status = BrokerAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.signup(
        email: _email!,
        password: _password!,
        fullName: fullName.trim(),
        mobile: _mobile!,
      );
      _status = BrokerAuthStatus.otpSent;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      if (_looksLikeAlreadyExists(e.message)) {
        try {
          await remoteDataSource.resendOtp(email: _email!);
        } catch (_) {}
        _status = BrokerAuthStatus.otpSent;
        notifyListeners();
        return true;
      }
      return _fail(e.message);
    } catch (e) {
      return _fail('Something went wrong. Please try again.');
    }
  }

  bool _fail(String message) {
    _status = BrokerAuthStatus.error;
    _errorMessage = message;
    notifyListeners();
    return false;
  }

  /// Email + password login against POST /auth/broker/login.
  Future<bool> loginWithEmail(String email, String password) async {
    if (!isValidEmail(email)) {
      _status = BrokerAuthStatus.error;
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }
    if (password.isEmpty) {
      _status = BrokerAuthStatus.error;
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return false;
    }

    _status = BrokerAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await remoteDataSource.login(
        email: email.trim(),
        password: password,
      );
      await localStorageService?.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await localStorageService?.setLoggedIn(
        isLoggedIn: true,
        authType: 'email',
      );
      _status = BrokerAuthStatus.success;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      _status = BrokerAuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = BrokerAuthStatus.error;
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Mobile login step 1: request an SMS login code for [tenDigitMobile]
  /// (the 10 digits after +91). Stores the mobile for the verify step.
  Future<bool> requestMobileLoginOtp(String tenDigitMobile) async {
    if (!isValidMobile(tenDigitMobile)) {
      return _fail('Please enter a valid 10-digit mobile number');
    }
    _mobile = '+91$tenDigitMobile';
    _status = BrokerAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await remoteDataSource.requestLoginOtp(mobile: _mobile!);
      _status = BrokerAuthStatus.otpSent;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Something went wrong. Please try again.');
    }
  }

  /// Mobile login step 2: verify the SMS code and sign in.
  Future<bool> verifyMobileLoginOtp(String otp) async {
    final mob = _mobile;
    if (mob == null) return _fail('Session expired. Please try again.');
    if (otp.length != 6) return _fail('Enter the 6-digit code');
    _status = BrokerAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final tokens = await remoteDataSource.verifyLoginOtp(
        mobile: mob,
        otp: otp,
      );
      await localStorageService?.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await localStorageService?.setLoggedIn(
        isLoggedIn: true,
        phoneNumber: mob,
        authType: 'mobile',
      );
      _status = BrokerAuthStatus.success;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Something went wrong. Please try again.');
    }
  }

  /// Resend the SMS login code to the current mobile.
  Future<bool> resendMobileLoginOtp() async {
    final mob = _mobile;
    if (mob == null) return false;
    try {
      await remoteDataSource.requestLoginOtp(mobile: mob);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Step 1 of password reset: email a reset code (POST /password-reset/request).
  Future<bool> requestPasswordReset(String email) async {
    if (!isValidEmail(email)) {
      return _fail('Please enter a valid email address');
    }
    _status = BrokerAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await remoteDataSource.requestPasswordReset(email: email.trim());
      _status = BrokerAuthStatus.initial;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Something went wrong. Please try again.');
    }
  }

  /// Step 2 of password reset: confirm with the code + new password
  /// (POST /password-reset/confirm).
  Future<bool> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (otp.length != 6) {
      return _fail('Enter the 6-digit code sent to your email');
    }
    if (!isValidPassword(newPassword)) {
      return _fail('Password must be at least 8 characters');
    }
    _status = BrokerAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await remoteDataSource.confirmPasswordReset(
        email: email.trim(),
        otp: otp,
        newPassword: newPassword,
      );
      _status = BrokerAuthStatus.initial;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Something went wrong. Please try again.');
    }
  }

  /// Restores a persisted session by exchanging the stored refresh token for a
  /// fresh access token. Only clears the login on a genuine auth failure — a
  /// transient network error keeps the session for the next launch.
  Future<SessionRestore> restoreSession() async {
    final refreshToken = await localStorageService?.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return SessionRestore.none;
    }
    try {
      final tokens = await remoteDataSource.refresh(refreshToken);
      await localStorageService?.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return SessionRestore.ok;
    } on ServerException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('network') || m.contains('connection')) {
        return SessionRestore.network; // keep session, retry later
      }
      await localStorageService?.setLoggedIn(isLoggedIn: false);
      return SessionRestore.invalid;
    } catch (_) {
      return SessionRestore.network;
    }
  }

  /// Resend the email OTP to the current signup address.
  Future<bool> resend() async {
    final mail = _email;
    if (mail == null) return false;
    try {
      await remoteDataSource.resendOtp(email: mail);
      return true;
    } catch (_) {
      return false;
    }
  }

  void reset() {
    _status = BrokerAuthStatus.initial;
    _errorMessage = null;
    _mobile = null;
    _email = null;
    _password = null;
    notifyListeners();
  }
}
