import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/onboarding_content.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, List<OnboardingContent>>> getOnboardingContent();
}
