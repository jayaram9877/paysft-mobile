import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/token_pair_model.dart';
import '../../models/user_model.dart';

/// Talks to the PaySFT broker auth endpoints.
///
/// Flow:
///   1. [signup]        -> creates the broker account, sends email + SMS OTPs
///   2. [verifyContact] -> verifies the email OTP and SMS OTP together
///   3. [login]         -> returns a TokenPair (broker is now signed in)
abstract class BrokerAuthRemoteDataSource {
  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
  });

  /// Verifies a broker's email OTP and SMS OTP together (both required).
  Future<void> verifyContact({
    required String email,
    required String emailOtp,
    required String mobileOtp,
  });

  Future<void> resendOtp({required String email});

  Future<TokenPairModel> login({
    required String email,
    required String password,
  });

  /// Requests an SMS login code for a broker by mobile (uniform response).
  Future<void> requestLoginOtp({required String mobile});

  /// Verifies an SMS login code and returns a TokenPair.
  Future<TokenPairModel> verifyLoginOtp({
    required String mobile,
    required String otp,
  });

  /// Exchanges a refresh token for a fresh TokenPair (POST /auth/refresh).
  Future<TokenPairModel> refresh(String refreshToken);

  /// Requests a password-reset code to be emailed.
  Future<void> requestPasswordReset({required String email});

  /// Confirms a password reset with the emailed code + new password.
  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  });

  /// Current signed-in user (GET /auth/me).
  Future<UserModel> getMe();

  /// Update full name and/or mobile (PATCH /auth/me).
  Future<UserModel> updateMe({String? fullName, String? mobile});

  /// Invalidate the refresh token server-side (POST /auth/logout).
  Future<void> logout(String refreshToken);
}

class BrokerAuthRemoteDataSourceImpl implements BrokerAuthRemoteDataSource {
  final Dio dio;

  BrokerAuthRemoteDataSourceImpl(this.dio);

  @override
  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.brokerSignup,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'mobile': mobile,
        },
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<void> verifyContact({
    required String email,
    required String emailOtp,
    required String mobileOtp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.brokerVerifyContact,
        data: {
          'email': email,
          'email_otp': emailOtp,
          'mobile_otp': mobileOtp,
        },
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      final response = await dio.post(
        ApiConstants.brokerResendOtp,
        data: {'email': email},
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<TokenPairModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.brokerLogin,
        data: {'email': email, 'password': password},
      );
      _ensureSuccess(response);
      return TokenPairModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<void> requestLoginOtp({required String mobile}) async {
    try {
      final response = await dio.post(
        ApiConstants.brokerLoginOtpRequest,
        data: {'mobile': mobile},
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<TokenPairModel> verifyLoginOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.brokerLoginOtpVerify,
        data: {'mobile': mobile, 'otp': otp},
      );
      _ensureSuccess(response);
      return TokenPairModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      final response = await dio.post(
        ApiConstants.passwordResetRequest,
        data: {'email': email},
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.passwordResetConfirm,
        data: {'email': email, 'otp': otp, 'new_password': newPassword},
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<TokenPairModel> refresh(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      _ensureSuccess(response);
      return TokenPairModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await dio.get(ApiConstants.authMe);
      _ensureSuccess(response);
      return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<UserModel> updateMe({String? fullName, String? mobile}) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (mobile != null) data['mobile'] = mobile;
      final response = await dio.patch(ApiConstants.authMe, data: data);
      _ensureSuccess(response);
      return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiConstants.authLogout,
        data: {'refresh_token': refreshToken},
      );
      _ensureSuccess(response);
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

  /// Extracts a human-readable message from the error body. PaySFT uses
  /// `{"error": {"code": "...", "message": "..."}}`; validation errors use the
  /// FastAPI `{"detail": "..."}` / `{"detail": [{"msg": "..."}]}` shape.
  String _messageFromBody(dynamic body, int status) {
    try {
      if (body is Map) {
        // PaySFT envelope: {"error": {"code": "...", "message": "..."}}
        final error = body['error'];
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
        // FastAPI: {"detail": "..."} or {"detail": [{"msg": "..."}]}
        final detail = body['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
        }
      }
    } catch (_) {
      // fall through to generic message
    }
    return 'Request failed (status $status). Please try again.';
  }
}
