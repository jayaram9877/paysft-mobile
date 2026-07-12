import 'package:flutter/foundation.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../core/errors/failures.dart';
import '../../core/services/local_storage_service.dart';

enum AuthStatus { initial, loading, otpSent, success, error }

class AuthProvider with ChangeNotifier {
  final SendOTP sendOTP;
  final VerifyOTP verifyOTP;
  final LocalStorageService? localStorageService;

  AuthProvider({
    required this.sendOTP,
    required this.verifyOTP,
    this.localStorageService,
  });

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _phoneNumber;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;

  Future<bool> sendOTPToUser(String phoneNumber) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _phoneNumber = phoneNumber;
    notifyListeners();

    final result = await sendOTP(SendOTPParams(phoneNumber));

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (_) {
        _status = AuthStatus.otpSent;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> verifyOTPForUser(String otp, String aphoneNumber) async {
    _phoneNumber = aphoneNumber;
    if (otp.length != 6) {
      _status = AuthStatus.error;
      _errorMessage = 'Phone number not found';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await verifyOTP(VerifyOTPParams(_phoneNumber!, otp));

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (isValid) {
        if (isValid) {
          _status = AuthStatus.success;
          localStorageService?.setLoggedIn(
            isLoggedIn: true,
            phoneNumber: _phoneNumber,
            authType: 'phone',
          );
          notifyListeners();
          return true;
        } else {
          _status = AuthStatus.success;
          _errorMessage = '';
          localStorageService?.setLoggedIn(
            isLoggedIn: true,
            phoneNumber: _phoneNumber,
            authType: 'phone',
          );
          notifyListeners();
          return true;
        }
      },
    );
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

  void reset() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    _phoneNumber = null;
    localStorageService?.setLoggedIn(isLoggedIn: false);
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    if (localStorageService == null) return;

    final isLoggedIn = await localStorageService!.isLoggedIn();
    if (isLoggedIn) {
      _status = AuthStatus.success;
      _phoneNumber = await localStorageService!.getPhoneNumber();
      notifyListeners();
    }
  }

  void logout() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    _phoneNumber = null;
    localStorageService?.setLoggedIn(isLoggedIn: false);
    notifyListeners();
  }
}
