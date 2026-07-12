import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Thin wrapper around Dio that standardizes how this backend is called.
/// The backend uses a shared `/api` endpoint with an `activity` query parameter.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response<dynamic>> postActivity({
    required String activity,
    required Map<String, dynamic> data,
    String? module,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) {
    return _dio.post(
      ApiConstants.apiPath,
      queryParameters: <String, dynamic>{
        ApiConstants.activityQueryKey: activity,
      },
      options: Options(
        headers: headers,
        extra: <String, dynamic>{
          if (module != null) ApiConstants.extraKeyModule: module,
        },
      ),
      data: data,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> getActivity({
    required String activity,
    String? module,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _dio.get(
      ApiConstants.apiPath,
      queryParameters: <String, dynamic>{
        ApiConstants.activityQueryKey: activity,
        ...?queryParameters,
      },
      options: Options(
        extra: <String, dynamic>{
          if (module != null) ApiConstants.extraKeyModule: module,
        },
      ),
      cancelToken: cancelToken,
    );
  }
}
