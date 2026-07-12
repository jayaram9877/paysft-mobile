import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignupParams {
  final String email;
  final String password;
  final String fullName;
  final String mobile;

  SignupParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.mobile,
  });
}

class SignupBuyer implements UseCase<void, SignupParams> {
  final AuthRepository repository;

  SignupBuyer(this.repository);

  @override
  Future<Either<Failure, void>> call(SignupParams params) async {
    return await repository.signup(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      mobile: params.mobile,
    );
  }
}
