import '../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOTP(String phoneNumber);
  Future<bool> verifyOTP(String phoneNumber, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // TODO: Inject Dio or HTTP client here for actual API calls
  // final Dio dio;
  // AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<void> sendOTP(String phoneNumber) async {
    try {
      // TODO: Implement actual API call
      // final response = await dio.post('/auth/send-otp', data: {
      //   'phoneNumber': phoneNumber,
      // });
      // if (response.statusCode != 200) {
      //   throw ServerException('Failed to send OTP');
      // }

      // Dummy API call - simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate success
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      // TODO: Implement actual API call
      // final response = await dio.post('/auth/verify-otp', data: {
      //   'phoneNumber': phoneNumber,
      //   'otp': otp,
      // });
      // if (response.statusCode == 200) {
      //   return response.data['success'] == true;
      // }
      // return false;

      // Dummy API call - simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Dummy validation: accept OTP 123456
      return otp == '123456';
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }
}
