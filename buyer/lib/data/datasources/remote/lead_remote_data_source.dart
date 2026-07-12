import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';

/// Buyer "interest" (lead) endpoints on the PaySFT demo backend:
///   GET  /buyer/leads                 -> the buyer's interests
///   POST /buyer/leads {unit_id,notes} -> register interest (idempotent per unit)
///   POST /buyer/leads/{id}/cancel     -> withdraw interest
abstract class LeadRemoteDataSource {
  /// Raw rows for every active (non-cancelled) interest. The provider derives
  /// both the unit_id -> lead_id map (for the buttons) and the enriched list
  /// (for the Favorites "Interested" tab) from these.
  Future<List<Map<String, dynamic>>> getActiveLeadRows();

  /// Registers interest in a unit and returns the lead id.
  Future<String> expressInterest(String unitId, {String? notes});

  /// Withdraws a previously registered interest.
  Future<void> cancelInterest(String leadId);
}

class LeadRemoteDataSourceImpl implements LeadRemoteDataSource {
  final Dio dio;

  LeadRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getActiveLeadRows() async {
    try {
      final resp = await dio.get(ApiConstants.buyerLeads);
      final data = resp.data;
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .where((m) => '${m['status']}' != 'cancelled')
          .map((m) => Map<String, dynamic>.from(m))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load your interests');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load your interests');
    }
  }

  @override
  Future<String> expressInterest(String unitId, {String? notes}) async {
    try {
      final resp = await dio.post(
        ApiConstants.buyerLeads,
        data: <String, dynamic>{
          'unit_id': unitId,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      final data = resp.data;
      final id = data is Map ? '${data['id'] ?? ''}' : '';
      if (id.isEmpty) throw ServerException('Could not register interest');
      return id;
    } on DioException catch (e) {
      throw _mapDioException(e, 'Could not register interest');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Could not register interest');
    }
  }

  @override
  Future<void> cancelInterest(String leadId) async {
    try {
      await dio.post('${ApiConstants.buyerLeads}/$leadId/cancel');
    } on DioException catch (e) {
      throw _mapDioException(e, 'Could not withdraw interest');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Could not withdraw interest');
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
