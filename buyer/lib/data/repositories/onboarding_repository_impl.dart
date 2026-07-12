import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/onboarding_content.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/remote/onboarding_remote_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OnboardingContent>>>
  getOnboardingContent() async {
    try {
      final responses = await remoteDataSource.getOnboardingContent();
      if (responses.isEmpty || responses.first.items.isEmpty) {
        return const Left(ServerFailure('No onboarding content available'));
      }
      return Right(responses.first.items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
