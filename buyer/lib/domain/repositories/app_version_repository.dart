import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/app_version_check.dart';

abstract class AppVersionRepository {
  Future<Either<Failure, AppVersionCheck>> verifyAppVersion(
    String currentVersion,
  );
}
