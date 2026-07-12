import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/app_version_check.dart';
import '../repositories/app_version_repository.dart';

class VerifyAppVersionParams {
  final String currentVersion;

  VerifyAppVersionParams(this.currentVersion);
}

class VerifyAppVersion
    implements UseCase<AppVersionCheck, VerifyAppVersionParams> {
  final AppVersionRepository repository;

  VerifyAppVersion(this.repository);

  @override
  Future<Either<Failure, AppVersionCheck>> call(
    VerifyAppVersionParams params,
  ) async {
    return repository.verifyAppVersion(params.currentVersion);
  }
}
