import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyOTPParams {
  final String phoneNumber;
  final String otp;

  VerifyOTPParams(this.phoneNumber, this.otp);
}

class VerifyOTP implements UseCase<bool, VerifyOTPParams> {
  final AuthRepository repository;

  VerifyOTP(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyOTPParams params) async {
    return await repository.verifyOTP(params.phoneNumber, params.otp);
  }
}
