import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../models/app_version/verify_app_version_response.dart';

abstract class AppVersionRemoteDataSource {
  Future<VerifyAppVersionResponse> verifyAppVersion(String currentVersion);
}

class AppVersionRemoteDataSourceImpl implements AppVersionRemoteDataSource {
  final ApiClient apiClient;

  AppVersionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<VerifyAppVersionResponse> verifyAppVersion(
    String currentVersion,
  ) async {
    try {
      final response = await apiClient.postActivity(
        activity: ApiConstants.activityVerifyAppVersion,
        module: ApiConstants.moduleBuyer,
        data: <String, dynamic>{'version': currentVersion},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;
      final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

      if (statusCode != 200) {
        throw ServerException(ApiErrorMessageExtractor.extract(json));
      }

      return VerifyAppVersionResponse.fromJson(json);
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
      throw ServerException('Failed to verify app version');
    }
  }
}
