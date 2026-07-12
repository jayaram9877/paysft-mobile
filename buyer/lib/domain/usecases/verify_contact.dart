import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class VerifyContactParams {
  final String email;
  final String emailOtp;
  final String mobileOtp;

  VerifyContactParams({
    required this.email,
    required this.emailOtp,
    required this.mobileOtp,
  });
}

/// Verifies signup contact (email + mobile OTPs) and returns the token pair.
class VerifyContact implements UseCase<AuthTokens, VerifyContactParams> {
  final AuthRepository repository;

  VerifyContact(this.repository);

  @override
  Future<Either<Failure, AuthTokens>> call(VerifyContactParams params) async {
    return await repository.verifyContact(
      email: params.email,
      emailOtp: params.emailOtp,
      mobileOtp: params.mobileOtp,
    );
  }
}
