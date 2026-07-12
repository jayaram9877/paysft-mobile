/// Mirrors the API `TokenPair` schema returned by set-password / login / refresh.
class TokenPairModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String? expiresAt;

  TokenPairModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    this.expiresAt,
  });

  factory TokenPairModel.fromJson(Map<String, dynamic> json) {
    return TokenPairModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'bearer',
      expiresAt: json['expires_at'] as String?,
    );
  }
}
