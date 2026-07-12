import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../../domain/entities/auth_tokens.dart';

abstract class AuthRemoteDataSource {
  /// Requests a login OTP for the given phone number.
  Future<void> sendOTP(String phoneNumber);

  /// Verifies the OTP and returns the access + refresh tokens on success.
  Future<AuthTokens> verifyOTP(String phoneNumber, String otp);

  /// Registers a new buyer. On success the backend sends OTPs to both the
  /// email and the mobile (account starts unverified).
  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
  });

  /// Verifies the signup contact (email + mobile OTPs) and returns the access +
  /// refresh tokens on success.
  Future<AuthTokens> verifyContact({
    required String email,
    required String emailOtp,
    required String mobileOtp,
  });

  /// Resends the signup OTPs for the given email.
  Future<void> resendSignupOtp(String email);
}

/// Talks to the PaySFT demo backend (REST) buyer auth endpoints:
///   POST /buyer/auth/login/otp/request  -> {"mobile": "+91XXXXXXXXXX"}
///   POST /buyer/auth/login/otp/verify   -> {"mobile": "...", "otp": "..."}
///
/// The backend requires mobile numbers to match `^\+91[6-9]\d{9}$`, so any
/// user input is normalized to `+91` + last 10 digits before sending.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.dio, required this.apiClient});

  /// Normalizes a user-entered phone string to the backend format
  /// `+91XXXXXXXXXX` (E.164, India).
  String _formatMobile(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final tenDigits =
        digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    return '${ApiConstants.mobileCountryCode}$tenDigits';
  }

  @override
  Future<void> sendOTP(String phoneNumber) async {
    try {
      final response = await dio.post(
        ApiConstants.buyerLoginOtpRequest,
        data: <String, dynamic>{'mobile': _formatMobile(phoneNumber)},
      );

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ServerException(
          ApiErrorMessageExtractor.extract(
            response.data,
            fallback: 'Failed to send OTP',
          ),
        );
      }
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to send OTP');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to send OTP');
    }
  }

  @override
  Future<AuthTokens> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await dio.post(
        ApiConstants.buyerLoginOtpVerify,
        data: <String, dynamic>{
          'mobile': _formatMobile(phoneNumber),
          'otp': otp,
        },
      );
      return _tokensFrom(response, 'OTP verification failed');
    } on DioException catch (e) {
      throw _mapDioException(e, 'OTP verification failed');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('OTP verification failed');
    }
  }

  @override
  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.buyerSignup,
        data: <String, dynamic>{
          'email': email.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'mobile': _formatMobile(mobile),
        },
      );

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ServerException(
          ApiErrorMessageExtractor.extract(
            response.data,
            fallback: 'Signup failed',
          ),
        );
      }
    } on DioException catch (e) {
      throw _mapDioException(e, 'Signup failed');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Signup failed');
    }
  }

  @override
  Future<AuthTokens> verifyContact({
    required String email,
    required String emailOtp,
    required String mobileOtp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.buyerVerifyContact,
        data: <String, dynamic>{
          'email': email.trim(),
          'email_otp': emailOtp,
          'mobile_otp': mobileOtp,
        },
      );
      return _tokensFrom(response, 'Verification failed');
    } on DioException catch (e) {
      throw _mapDioException(e, 'Verification failed');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Verification failed');
    }
  }

  /// Parses an `{access_token, refresh_token, ...}` auth response.
  AuthTokens _tokensFrom(Response<dynamic> response, String fallback) {
    final status = response.statusCode ?? 0;
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final token = json['access_token'];
    final refresh = json['refresh_token'];

    final isSuccess =
        status >= 200 && status < 300 && token is String && token.isNotEmpty;
    if (!isSuccess) {
      throw ServerException(
        ApiErrorMessageExtractor.extract(body, fallback: fallback),
      );
    }
    return AuthTokens(
      accessToken: token as String,
      refreshToken: refresh is String ? refresh : null,
    );
  }

  @override
  Future<void> resendSignupOtp(String email) async {
    try {
      final response = await dio.post(
        ApiConstants.buyerResendOtp,
        data: <String, dynamic>{'email': email.trim()},
      );

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ServerException(
          ApiErrorMessageExtractor.extract(
            response.data,
            fallback: 'Failed to resend code',
          ),
        );
      }
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to resend code');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to resend code');
    }
  }

  Exception _mapDioException(DioException e, String fallback) {
    // If the server responded with an error body, surface its message.
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
