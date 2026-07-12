import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class VerifyOTPParams {
  final String phoneNumber;
  final String otp;

  VerifyOTPParams(this.phoneNumber, this.otp);
}

/// Validates OTP and returns the token pair on success.
class VerifyOTP implements UseCase<AuthTokens, VerifyOTPParams> {
  final AuthRepository repository;

  VerifyOTP(this.repository);

  @override
  Future<Either<Failure, AuthTokens>> call(VerifyOTPParams params) async {
    return await repository.verifyOTP(params.phoneNumber, params.otp);
  }
}
