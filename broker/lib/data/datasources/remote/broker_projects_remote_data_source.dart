import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/broker_project_model.dart';
import '../../models/broker_unit_model.dart';
import '../../models/broker_project_media_model.dart';

abstract class BrokerProjectsRemoteDataSource {
  /// Browse the live-project catalog. [q] is a server-side search across name /
  /// locality / city; null or empty returns everything (first page).
  Future<List<BrokerProjectModel>> listProjects({String? q});
  Future<BrokerProjectModel> getProject(String projectId);
  Future<List<BrokerUnitModel>> getUnits(String projectId);
  Future<List<BrokerProjectMediaModel>> getMedia(String projectId);
}

class BrokerProjectsRemoteDataSourceImpl
    implements BrokerProjectsRemoteDataSource {
  final Dio dio;

  BrokerProjectsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<BrokerProjectModel>> listProjects({String? q}) async {
    try {
      final res = await dio.get(
        ApiConstants.brokersMeProjects,
        queryParameters: {
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        },
      );
      final status = res.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ServerException(_message(res.data, status));
      }
      // The listing now returns a BrokerProjectPage ({items, total, limit,
      // offset}); older builds returned a bare array. Handle both.
      final data = res.data;
      final List list = data is List
          ? data
          : (data is Map && data['items'] is List
              ? data['items'] as List
              : const []);
      return list
          .whereType<Map>()
          .map((e) => BrokerProjectModel.fromJson(
              Map<String, dynamic>.from(e)))
          .toList();
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
  Future<BrokerProjectModel> getProject(String projectId) async {
    try {
      final res = await dio.get(ApiConstants.brokerProject(projectId));
      final status = res.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ServerException(_message(res.data, status));
      }
      final data = res.data;
      if (data is Map) {
        return BrokerProjectModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw const ServerException('Unexpected project response.');
    } on DioException catch (e) {
      throw ServerException(e.response != null
          ? _message(e.response!.data, e.response!.statusCode ?? 0)
          : 'Network error. Please check your connection and try again.');
    }
  }

  @override
  Future<List<BrokerUnitModel>> getUnits(String projectId) async {
    // Resilient: a project may have no units yet — return empty on failure.
    try {
      final res = await dio.get(ApiConstants.brokerProjectUnits(projectId));
      final data = res.data;
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => BrokerUnitModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<BrokerProjectMediaModel>> getMedia(String projectId) async {
    try {
      final res = await dio.get(ApiConstants.brokerProjectMedia(projectId));
      final data = res.data;
      if (data is! List) return [];
      final list = data
          .whereType<Map>()
          .map((e) =>
              BrokerProjectMediaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return list;
    } catch (_) {
      return [];
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
    return 'Could not load properties (status $status).';
  }
}
