import 'package:equatable/equatable.dart';

/// Access + refresh token pair returned by the auth endpoints
/// (login OTP verify, signup verify-contact, refresh).
class AuthTokens extends Equatable {
  final String accessToken;
  final String? refreshToken;

  const AuthTokens({required this.accessToken, this.refreshToken});

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
