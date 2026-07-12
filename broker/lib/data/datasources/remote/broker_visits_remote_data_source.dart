import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/broker_visit_model.dart';

abstract class BrokerVisitsRemoteDataSource {
  /// GET /brokers/me/visits — the broker's scheduled site visits.
  Future<List<BrokerVisitModel>> listVisits();

  /// POST /brokers/me/leads/{leadId}/visits — schedule a visit for a lead.
  Future<BrokerVisitModel> scheduleVisit({
    required String leadId,
    required DateTime scheduledFor,
    String? notes,
  });

  /// PATCH /brokers/me/visits/{id} — reschedule a visit.
  Future<BrokerVisitModel> rescheduleVisit({
    required String visitId,
    required DateTime scheduledFor,
  });

  /// POST /brokers/me/visits/{id}/cancel — cancel a scheduled visit.
  Future<void> cancelVisit(String visitId);
}

class BrokerVisitsRemoteDataSourceImpl implements BrokerVisitsRemoteDataSource {
  final Dio dio;

  BrokerVisitsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<BrokerVisitModel>> listVisits() async {
    try {
      final res = await dio.get(ApiConstants.brokersMeVisits);
      final data = res.data;
      final List list = data is List
          ? data
          : (data is Map && data['items'] is List ? data['items'] as List : const []);
      return list
          .whereType<Map>()
          .map((e) => BrokerVisitModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      // Resilient: an empty/failed visits call shouldn't break the screen.
      return [];
    }
  }

  @override
  Future<BrokerVisitModel> scheduleVisit({
    required String leadId,
    required DateTime scheduledFor,
    String? notes,
  }) async {
    return _writeVisit(
      () => dio.post(
        ApiConstants.brokerLeadVisits(leadId),
        data: {
          'scheduled_for': scheduledFor.toUtc().toIso8601String(),
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      ),
    );
  }

  @override
  Future<BrokerVisitModel> rescheduleVisit({
    required String visitId,
    required DateTime scheduledFor,
  }) async {
    return _writeVisit(
      () => dio.patch(
        ApiConstants.brokerVisit(visitId),
        data: {'scheduled_for': scheduledFor.toUtc().toIso8601String()},
      ),
    );
  }

  Future<BrokerVisitModel> _writeVisit(Future<Response> Function() call) async {
    try {
      final res = await call();
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        throw ServerException(_message(res.data, code));
      }
      final data = res.data;
      if (data is Map) {
        return BrokerVisitModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw const ServerException('Unexpected response from the visit API.');
    } on DioException catch (e) {
      throw ServerException(e.response != null
          ? _message(e.response!.data, e.response!.statusCode ?? 0)
          : 'Network error. Please check your connection and try again.');
    }
  }

  @override
  Future<void> cancelVisit(String visitId) async {
    try {
      final res = await dio.post(ApiConstants.brokerVisitCancel(visitId));
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        throw ServerException(_message(res.data, code));
      }
    } on DioException catch (e) {
      throw ServerException(e.response != null
          ? _message(e.response!.data, e.response!.statusCode ?? 0)
          : 'Network error. Please check your connection and try again.');
    }
  }

  String _message(dynamic body, int status) {
    try {
      if (body is Map) {
        final err = body['error'];
        if (err is Map && err['message'] != null) return err['message'].toString();
        final detail = body['detail'];
        if (detail is String) return detail;
      }
    } catch (_) {}
    return 'Could not cancel this visit (status $status).';
  }
}
