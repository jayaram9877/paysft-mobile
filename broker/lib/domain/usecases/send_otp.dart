import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendOTPParams {
  final String phoneNumber;

  SendOTPParams(this.phoneNumber);
}

class SendOTP implements UseCase<void, SendOTPParams> {
  final AuthRepository repository;

  SendOTP(this.repository);

  @override
  Future<Either<Failure, void>> call(SendOTPParams params) async {
    return await repository.sendOTP(params.phoneNumber);
  }
}
