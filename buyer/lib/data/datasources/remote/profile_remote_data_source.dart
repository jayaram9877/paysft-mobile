import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../../domain/entities/buyer_profile.dart';

/// Buyer profile + session endpoints on the PaySFT demo backend:
///   GET   /buyer/me          -> profile
///   PATCH /buyer/me          -> update profile
///   POST  /buyer/auth/logout -> invalidate session
abstract class ProfileRemoteDataSource {
  Future<BuyerProfile> getMe();
  Future<BuyerProfile> updateMe(Map<String, dynamic> body);
  Future<void> logout({String? refreshToken});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<BuyerProfile> getMe() async {
    try {
      final response = await dio.get(ApiConstants.buyerMe);
      return _profileFrom(response);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load profile');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load profile');
    }
  }

  @override
  Future<BuyerProfile> updateMe(Map<String, dynamic> body) async {
    try {
      final response = await dio.patch(ApiConstants.buyerMe, data: body);
      return _profileFrom(response);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to update profile');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update profile');
    }
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    try {
      await dio.post(
        ApiConstants.buyerLogout,
        data: <String, dynamic>{
          if (refreshToken != null && refreshToken.isNotEmpty)
            'refresh_token': refreshToken,
        },
      );
    } on DioException catch (e) {
      throw _mapDioException(e, 'Logout failed');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Logout failed');
    }
  }

  BuyerProfile _profileFrom(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final body = response.data;
    if (status < 200 || status >= 300 || body is! Map<String, dynamic>) {
      throw ServerException(
        ApiErrorMessageExtractor.extract(body, fallback: 'Failed to load profile'),
      );
    }
    return BuyerProfile.fromJson(body);
  }

  Exception _mapDioException(DioException e, String fallback) {
    if (e.response?.data != null) {
      return ServerException(
        ApiErrorMessageExtractor.extract(e.response!.data, fallback: fallback),
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );
      default:
        return NetworkException(e.message ?? 'Network error. Please try again.');
    }
  }
}
