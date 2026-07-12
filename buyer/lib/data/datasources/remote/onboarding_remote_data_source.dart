import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../models/onboarding/onboarding_content_response.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingContentResponse>> getOnboardingContent();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final ApiClient apiClient;

  OnboardingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OnboardingContentResponse>> getOnboardingContent() async {
    try {
      final response = await apiClient.getActivity(
        activity: ApiConstants.activityGetOnboardingContent,
        module: ApiConstants.moduleBuyer,
      );

      final status = response.statusCode ?? 0;
      final body = response.data;
      final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

      if (status != 200) {
        throw ServerException(ApiErrorMessageExtractor.extract(json));
      }

      return <OnboardingContentResponse>[
        OnboardingContentResponse.fromJson(json),
      ];
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ServerException(
          ApiErrorMessageExtractor.extract(e.response!.data),
        );
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw NetworkException('Request timed out. Please try again.');
        case DioExceptionType.connectionError:
          throw NetworkException(
            'No internet connection. Please check your network.',
          );
        default:
          throw NetworkException(
            e.message ?? 'Network error. Please try again.',
          );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch onboarding content');
    }
  }
}
