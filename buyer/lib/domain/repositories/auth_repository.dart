import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOTP(String phoneNumber);

  /// Returns the token pair if verification succeeds.
  Future<Either<Failure, AuthTokens>> verifyOTP(String phoneNumber, String otp);

  /// Registers a new buyer (backend then sends email + mobile OTPs).
  Future<Either<Failure, void>> signup({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
  });

  /// Verifies signup contact and returns the token pair on success.
  Future<Either<Failure, AuthTokens>> verifyContact({
    required String email,
    required String emailOtp,
    required String mobileOtp,
  });

  /// Resends signup OTPs for the given email.
  Future<Either<Failure, void>> resendSignupOtp(String email);
}


