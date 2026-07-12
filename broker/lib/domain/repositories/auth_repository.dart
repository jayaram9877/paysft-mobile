import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOTP(String phoneNumber);
  Future<Either<Failure, bool>> verifyOTP(String phoneNumber, String otp);
}
