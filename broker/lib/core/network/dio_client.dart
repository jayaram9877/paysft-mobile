import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/local_storage_service.dart';

/// Configured Dio instance used for all network calls.
class DioClient {
  static Dio create({LocalStorageService? localStorageService}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
        // We handle non-2xx ourselves so we can read error bodies.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Attach the stored access token as a Bearer header for authenticated calls.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await localStorageService?.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );

    return dio;
  }
}
