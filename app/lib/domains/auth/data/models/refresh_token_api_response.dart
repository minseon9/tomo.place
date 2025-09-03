class RefreshTokenApiResponse {
  final String accessToken;
  final int accessTokenExpiresAt;
  final String refreshToken;
  final int refreshTokenExpiresAt;

  const RefreshTokenApiResponse({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory RefreshTokenApiResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenApiResponse(
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] as int,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] as int,
    );
  }
}
