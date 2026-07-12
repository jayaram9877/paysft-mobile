import 'package:dio/dio.dart';

import '../config/app_flavor.dart';
import '../constants/api_constants.dart';
import '../services/local_storage_service.dart';

class DioClient {
  /// Invoked when the session can't be recovered (refresh failed / no refresh
  /// token). Set by the app layer to redirect the user to the login screen.
  static void Function()? onSessionExpired;

  // Single-flight guard so concurrent 401s trigger only one refresh call.
  static Future<bool>? _refreshing;

  static Dio create(AppConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: ApiConstants.jsonHeaders,
      ),
    );

    final localStorage = LocalStorageService();

    dio.interceptors.add(
      InterceptorsWrapper(
        // Attach common headers + bearer token + optional module header.
        onRequest: (options, handler) async {
          options.headers.putIfAbsent(
            ApiConstants.contentTypeHeaderKey,
            () => ApiConstants.contentTypeJson,
          );

          // Bearer auth for protected endpoints (e.g. GET /buyer/projects).
          if (!options.headers.containsKey(
            ApiConstants.authorizationHeaderKey,
          )) {
            final token = await localStorage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers[ApiConstants.authorizationHeaderKey] =
                  '${ApiConstants.bearerPrefix}$token';
            }
          }

          final module = options.extra[ApiConstants.extraKeyModule];
          if (module is String && module.isNotEmpty) {
            options.headers[ApiConstants.moduleHeaderKey] = module;
            // Some gateways normalize headers differently; set lowercase key too.
            options.headers['module'] = module;
          }

          handler.next(options);
        },

        // On a 401, try to refresh the access token once and replay the request.
        onError: (error, handler) async {
          final shouldRefresh = error.response?.statusCode == 401 &&
              !_isAuthPath(error.requestOptions.path) &&
              error.requestOptions.extra['__retried__'] != true;

          if (!shouldRefresh) {
            handler.next(error);
            return;
          }

          // Coalesce concurrent refreshes into one network call.
          _refreshing ??= _refreshTokens(config.baseUrl, localStorage);
          final refreshed = await _refreshing!;
          _refreshing = null;

          if (!refreshed) {
            await localStorage.setLoggedIn(isLoggedIn: false);
            onSessionExpired?.call();
            handler.next(error);
            return;
          }

          // Replay the original request with the new access token.
          try {
            final newToken = await localStorage.getAccessToken();
            final options = error.requestOptions;
            options.headers[ApiConstants.authorizationHeaderKey] =
                '${ApiConstants.bearerPrefix}$newToken';
            options.extra['__retried__'] = true;
            final response = await dio.fetch(options);
            handler.resolve(response);
          } on DioException catch (e) {
            handler.next(e);
          }
        },
      ),
    );

    if (config.enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }

    return dio;
  }

  static bool _isAuthPath(String path) => path.contains('/buyer/auth/');

  /// Exchanges the stored refresh token for a new token pair. Returns true on
  /// success. Uses a bare Dio so it never re-enters this interceptor.
  static Future<bool> _refreshTokens(
    String baseUrl,
    LocalStorageService localStorage,
  ) async {
    final refreshToken = await localStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final bare = Dio(BaseOptions(baseUrl: baseUrl, headers: ApiConstants.jsonHeaders));
      final response = await bare.post(
        ApiConstants.buyerRefresh,
        data: <String, dynamic>{'refresh_token': refreshToken},
      );
      final data = response.data;
      final status = response.statusCode ?? 0;
      if (status >= 200 &&
          status < 300 &&
          data is Map<String, dynamic> &&
          data['access_token'] is String) {
        await localStorage.updateTokens(
          accessToken: data['access_token'] as String,
          refreshToken:
              data['refresh_token'] is String ? data['refresh_token'] as String : null,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
