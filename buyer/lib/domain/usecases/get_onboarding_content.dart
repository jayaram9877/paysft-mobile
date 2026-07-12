import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/onboarding_content.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingContent
    implements UseCase<List<OnboardingContent>, NoParams> {
  final OnboardingRepository repository;

  GetOnboardingContent(this.repository);

  @override
  Future<Either<Failure, List<OnboardingContent>>> call(NoParams params) async {
    return repository.getOnboardingContent();
  }
}
