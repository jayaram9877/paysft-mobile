import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendSignupOtpParams {
  final String email;

  ResendSignupOtpParams(this.email);
}

class ResendSignupOtp implements UseCase<void, ResendSignupOtpParams> {
  final AuthRepository repository;

  ResendSignupOtp(this.repository);

  @override
  Future<Either<Failure, void>> call(ResendSignupOtpParams params) async {
    return await repository.resendSignupOtp(params.email);
  }
}
