import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/broker_model.dart';

/// Authenticated broker KYC endpoints (require a Bearer token).
abstract class BrokerKycRemoteDataSource {
  /// Returns the signed-in user's broker profile, or null if none exists (404).
  Future<BrokerModel?> getMyBroker();

  Future<BrokerModel> createBroker({
    required String legalName,
    required String entityType,
    required String pan,
    required String registeredAddress,
    String? reraAgentNumber,
    String? reraAgentState,
    String? bankAccountNumber,
    String? bankAccountHolderName,
    String? bankIfsc,
    String? bankName,
  });

  /// Returns the list of uploaded documents (raw maps).
  Future<List<dynamic>> listDocuments();

  Future<void> uploadDocument({
    required String documentType,
    required String filePath,
    required String fileName,
  });

  Future<BrokerModel> submitForReview();
}

class BrokerKycRemoteDataSourceImpl implements BrokerKycRemoteDataSource {
  final Dio dio;

  BrokerKycRemoteDataSourceImpl(this.dio);

  @override
  Future<BrokerModel?> getMyBroker() async {
    try {
      final response = await dio.get(ApiConstants.brokersMe);
      if (response.statusCode == 404) return null;
      _ensureSuccess(response);
      return BrokerModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<BrokerModel> createBroker({
    required String legalName,
    required String entityType,
    required String pan,
    required String registeredAddress,
    String? reraAgentNumber,
    String? reraAgentState,
    String? bankAccountNumber,
    String? bankAccountHolderName,
    String? bankIfsc,
    String? bankName,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.brokers,
        data: {
          'legal_name': legalName,
          'entity_type': entityType,
          'pan': pan,
          'registered_address': registeredAddress,
          if (reraAgentNumber != null) 'rera_agent_number': reraAgentNumber,
          if (reraAgentState != null) 'rera_agent_state': reraAgentState,
          if (bankAccountNumber != null)
            'bank_account_number': bankAccountNumber,
          if (bankAccountHolderName != null)
            'bank_account_holder_name': bankAccountHolderName,
          if (bankIfsc != null) 'bank_ifsc': bankIfsc,
          if (bankName != null) 'bank_name': bankName,
        },
      );
      _ensureSuccess(response);
      return BrokerModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<List<dynamic>> listDocuments() async {
    try {
      final response = await dio.get(ApiConstants.brokersMeDocuments);
      _ensureSuccess(response);
      final data = response.data;
      return data is List ? data : <dynamic>[];
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<void> uploadDocument({
    required String documentType,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'document_type': documentType,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await dio.post(
        ApiConstants.brokersMeDocuments,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<BrokerModel> submitForReview() async {
    try {
      final response = await dio.post(ApiConstants.brokersMeSubmit);
      _ensureSuccess(response);
      return BrokerModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  void _ensureSuccess(Response response) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return;
    throw ServerException(_messageFromBody(response.data, status));
  }

  String _messageFromDio(DioException e) {
    if (e.response != null) {
      return _messageFromBody(e.response!.data, e.response!.statusCode ?? 0);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Network error. Please check your connection and try again.';
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }

  String _messageFromBody(dynamic body, int status) {
    try {
      if (body is Map) {
        final error = body['error'];
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
        final detail = body['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
        }
      }
    } catch (_) {}
    return 'Request failed (status $status). Please try again.';
  }
}
