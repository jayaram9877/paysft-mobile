import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../../domain/entities/favorite_unit.dart';
import 'favorite_unit_mapper.dart';

/// Buyer saved-units ("favorites") endpoints on the PaySFT demo backend:
///   GET    /buyer/saved-units             -> saved units
///   POST   /buyer/saved-units {unit_id}   -> save a unit
///   DELETE /buyer/saved-units/{unit_id}   -> remove a saved unit
abstract class SavedUnitsRemoteDataSource {
  Future<List<FavoriteUnit>> getSavedUnits();
  Future<void> saveUnit(String unitId);
  Future<void> removeSavedUnit(String unitId);
}

class SavedUnitsRemoteDataSourceImpl implements SavedUnitsRemoteDataSource {
  final Dio dio;

  SavedUnitsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FavoriteUnit>> getSavedUnits() async {
    try {
      final resp = await dio.get(ApiConstants.buyerSavedUnits);
      final data = resp.data;
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map(FavoriteUnitMapper.fromSavedUnit)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load your saved units');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load your saved units');
    }
  }

  @override
  Future<void> saveUnit(String unitId) async {
    try {
      await dio.post(
        ApiConstants.buyerSavedUnits,
        data: <String, dynamic>{'unit_id': unitId},
      );
    } on DioException catch (e) {
      throw _mapDioException(e, 'Could not save this unit');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Could not save this unit');
    }
  }

  @override
  Future<void> removeSavedUnit(String unitId) async {
    try {
      await dio.delete('${ApiConstants.buyerSavedUnits}/$unitId');
    } on DioException catch (e) {
      throw _mapDioException(e, 'Could not remove this unit');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Could not remove this unit');
    }
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
