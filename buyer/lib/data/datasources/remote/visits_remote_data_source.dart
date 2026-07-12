import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../../domain/entities/visit_meeting.dart';

/// Buyer site visits ("meetings") on the PaySFT demo backend:
///   GET /buyer/visits -> the buyer's scheduled/past visits.
abstract class VisitsRemoteDataSource {
  Future<List<VisitMeeting>> getVisits();
}

class VisitsRemoteDataSourceImpl implements VisitsRemoteDataSource {
  final Dio dio;

  VisitsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<VisitMeeting>> getVisits() async {
    try {
      final resp = await dio.get(ApiConstants.buyerVisits);
      final data = resp.data;
      if (data is! List) return const [];
      final visits = data.whereType<Map>().map(_fromJson).toList(growable: false);
      return Future.wait(visits.map(_withBrokerName));
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load your meetings');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load your meetings');
    }
  }

  VisitMeeting _fromJson(Map m) {
    final raw = _str(m['scheduled_for']);
    final parsed = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    return VisitMeeting(
      id: '${m['id'] ?? ''}',
      leadId: '${m['lead_id'] ?? ''}',
      projectId: '${m['project_id'] ?? ''}',
      unitId: '${m['unit_id'] ?? ''}',
      scheduledFor: parsed,
      status: _str(m['status']) ?? '',
      notes: _str(m['notes']),
      projectName: _str(m['project_name']) ?? '',
      unitTitle: _str(m['unit_title']) ?? '',
      unitNumber: _str(m['unit_number']) ?? '',
    );
  }

  /// Best-effort broker name lookup via GET /buyer/leads/{lead_id} (the lead
  /// detail endpoint reveals the matched broker's contact once accepted).
  /// Silently leaves the visit unchanged on any failure (e.g. no broker yet).
  Future<VisitMeeting> _withBrokerName(VisitMeeting v) async {
    if (v.leadId.isEmpty) return v;
    try {
      final resp = await dio.get('${ApiConstants.buyerLeads}/${v.leadId}');
      final body = resp.data;
      final broker = body is Map ? body['broker'] : null;
      if (broker is! Map) return v;
      final name = _str(broker['contact_name']) ?? _str(broker['legal_name']);
      if (name == null || name.isEmpty) return v;
      return v.copyWith(brokerName: name);
    } catch (_) {
      return v;
    }
  }

  String? _str(dynamic v) => v == null ? null : '$v';

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
