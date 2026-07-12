import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/onboarding_content.dart';
import '../../domain/usecases/get_onboarding_content.dart';

enum OnboardingStatus { initial, loading, loaded, error }

class OnboardingProvider with ChangeNotifier {
  final GetOnboardingContent getOnboardingContent;

  OnboardingProvider({required this.getOnboardingContent});

  OnboardingStatus _status = OnboardingStatus.initial;
  String? _errorMessage;
  List<OnboardingContent> _items = const [];

  OnboardingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<OnboardingContent> get items => _items;

  Future<void> fetchOnboardingContent() async {
    if (_status == OnboardingStatus.loading) return;

    _status = OnboardingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getOnboardingContent(NoParams());
    result.fold(
      (failure) {
        _status = OnboardingStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
      },
      (items) {
        _status = OnboardingStatus.loaded;
        _items = items;
      },
    );

    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      default:
        return 'Unexpected error: ${failure.message}';
    }
  }
}
