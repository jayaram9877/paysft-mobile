import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../../core/services/local_storage_service.dart';
import '../../domain/usecases/resend_signup_otp.dart';
import '../../domain/usecases/signup_buyer.dart';
import '../../domain/usecases/verify_contact.dart';

enum SignupStatus { initial, submitting, otpSent, verifying, verified, error }

/// Drives the buyer self-signup flow:
///   signup (email/password/name/mobile) -> verify-contact (email + mobile OTP)
/// The same instance is shared across the signup and verify screens so the
/// email/mobile captured at signup are available when verifying.
class SignupProvider with ChangeNotifier {
  final SignupBuyer signupBuyer;
  final VerifyContact verifyContactUseCase;
  final ResendSignupOtp resendSignupOtp;
  final LocalStorageService? localStorageService;

  SignupProvider({
    required this.signupBuyer,
    required this.verifyContactUseCase,
    required this.resendSignupOtp,
    this.localStorageService,
  });

  SignupStatus _status = SignupStatus.initial;
  String? _errorMessage;
  String _email = '';
  String _mobile = '';

  SignupStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get email => _email;
  String get mobile => _mobile;
  bool get isBusy =>
      _status == SignupStatus.submitting || _status == SignupStatus.verifying;

  /// Step 1 — create the account. On success the backend sends OTPs to both
  /// the email and the mobile.
  Future<bool> submitSignup({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
  }) async {
    _status = SignupStatus.submitting;
    _errorMessage = null;
    _email = email.trim();
    _mobile = mobile.trim();
    notifyListeners();

    final result = await signupBuyer(
      SignupParams(
        email: email,
        password: password,
        fullName: fullName,
        mobile: mobile,
      ),
    );

    return result.fold(
      (failure) {
        _status = SignupStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (_) {
        _status = SignupStatus.otpSent;
        notifyListeners();
        return true;
      },
    );
  }

  /// Step 2 — verify email + mobile OTPs. Persists the returned access token
  /// and marks the user logged in on success.
  Future<bool> verify({
    required String emailOtp,
    required String mobileOtp,
  }) async {
    _status = SignupStatus.verifying;
    _errorMessage = null;
    notifyListeners();

    final result = await verifyContactUseCase(
      VerifyContactParams(
        email: _email,
        emailOtp: emailOtp,
        mobileOtp: mobileOtp,
      ),
    );

    return result.fold(
      (failure) {
        _status = SignupStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (tokens) {
        _status = SignupStatus.verified;
        localStorageService?.setLoggedIn(
          isLoggedIn: true,
          phoneNumber: _mobile,
          authType: 'email',
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Resends the signup OTPs. Returns the error message on failure, null on
  /// success.
  Future<String?> resend() async {
    final result = await resendSignupOtp(ResendSignupOtpParams(_email));
    return result.fold(_mapFailureToMessage, (_) => null);
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
