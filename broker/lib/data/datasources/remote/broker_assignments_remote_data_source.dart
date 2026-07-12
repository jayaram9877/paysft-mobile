import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/broker_assignment_model.dart';
import '../../models/broker_offer_model.dart';
import '../../models/broker_client_model.dart';

abstract class BrokerAssignmentsRemoteDataSource {
  /// GET /brokers/me/assignments — the broker's project alignments.
  Future<List<BrokerAssignmentModel>> listAssignments();

  /// POST /brokers/me/assignments — align the broker to a project.
  Future<BrokerAssignmentModel> alignProject(String projectId);

  /// PATCH /brokers/me/assignments/{id} — change an assignment's status
  /// (e.g. pause / resume).
  Future<BrokerAssignmentModel> updateAssignmentStatus(
      String assignmentId, String status);

  /// DELETE /brokers/me/assignments/{id} — revoke (unalign) an assignment.
  Future<void> revokeAssignment(String assignmentId);

  /// GET /brokers/me/leads — pending lead offers routed to the broker.
  Future<List<BrokerOfferModel>> listLeads();

  /// POST /brokers/me/leads/{id}/accept — accept a lead; returns the client.
  Future<BrokerClientModel> acceptLead(String leadId);

  /// POST /brokers/me/leads/{id}/reject — reject a lead.
  Future<void> rejectLead(String leadId, {String? reason});

  /// GET /brokers/me/clients — leads the broker has accepted (clients).
  Future<List<BrokerClientModel>> listClients();
}

class BrokerAssignmentsRemoteDataSourceImpl
    implements BrokerAssignmentsRemoteDataSource {
  final Dio dio;

  BrokerAssignmentsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<BrokerAssignmentModel>> listAssignments() async {
    // Resilient: alignments are supplementary to the projects list, so a
    // failure here returns empty rather than breaking the whole screen.
    try {
      final res = await dio.get(ApiConstants.brokersMeAssignments);
      final data = res.data;
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) =>
              BrokerAssignmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<BrokerAssignmentModel> alignProject(String projectId) async {
    try {
      final res = await dio.post(
        ApiConstants.brokersMeAssignments,
        data: {'project_id': projectId},
      );
      final status = res.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ServerException(_message(res.data, status));
      }
      final data = res.data;
      if (data is Map) {
        return BrokerAssignmentModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw const ServerException('Unexpected response while aligning.');
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
            _message(e.response!.data, e.response!.statusCode ?? 0));
      }
      throw const ServerException(
          'Network error. Please check your connection and try again.');
    }
  }

  @override
  Future<BrokerAssignmentModel> updateAssignmentStatus(
      String assignmentId, String status) async {
    try {
      final res = await dio.patch(
        ApiConstants.brokerAssignment(assignmentId),
        data: {'status': status},
      );
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        throw ServerException(_message(res.data, code));
      }
      final data = res.data;
      if (data is Map) {
        return BrokerAssignmentModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw const ServerException('Unexpected response while updating.');
    } on DioException catch (e) {
      throw ServerException(e.response != null
          ? _message(e.response!.data, e.response!.statusCode ?? 0)
          : 'Network error. Please check your connection and try again.');
    }
  }

  @override
  Future<void> revokeAssignment(String assignmentId) async {
    try {
      final res = await dio.delete(ApiConstants.brokerAssignment(assignmentId));
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

  @override
  Future<List<BrokerOfferModel>> listLeads() async {
    try {
      final res = await dio.get(ApiConstants.brokersMeLeads);
      final data = res.data;
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => BrokerOfferModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<BrokerClientModel> acceptLead(String leadId) async {
    try {
      final res = await dio.post(ApiConstants.brokerLeadAccept(leadId));
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        throw ServerException(_message(res.data, code));
      }
      final data = res.data;
      if (data is Map) {
        return BrokerClientModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw const ServerException('Unexpected response while accepting lead.');
    } on DioException catch (e) {
      throw ServerException(e.response != null
          ? _message(e.response!.data, e.response!.statusCode ?? 0)
          : 'Network error. Please check your connection and try again.');
    }
  }

  @override
  Future<void> rejectLead(String leadId, {String? reason}) async {
    try {
      final res = await dio.post(
        ApiConstants.brokerLeadReject(leadId),
        data: {if (reason != null && reason.isNotEmpty) 'rejection_reason': reason},
      );
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

  @override
  Future<List<BrokerClientModel>> listClients() async {
    try {
      final res = await dio.get(ApiConstants.brokersMeClients);
      final data = res.data;
      final List list = data is List
          ? data
          : (data is Map && data['items'] is List ? data['items'] as List : const []);
      return list
          .whereType<Map>()
          .map((e) => BrokerClientModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _message(dynamic body, int status) {
    try {
      if (body is Map) {
        final err = body['error'];
        if (err is Map && err['message'] != null) {
          return err['message'].toString();
        }
        final detail = body['detail'];
        if (detail is String) return detail;
      }
    } catch (_) {}
    return 'Could not align this property (status $status).';
  }
}
