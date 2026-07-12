import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/app_version_check.dart';
import '../../domain/repositories/app_version_repository.dart';
import '../datasources/remote/app_version_remote_data_source.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionRemoteDataSource remoteDataSource;

  AppVersionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppVersionCheck>> verifyAppVersion(
    String currentVersion,
  ) async {
    try {
      final response = await remoteDataSource.verifyAppVersion(currentVersion);
      return Right(response.toEntity(currentVersion));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
