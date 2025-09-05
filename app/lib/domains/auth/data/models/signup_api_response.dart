class SignupApiResponse {
  final String accessToken;
  final int accessTokenExpiresAt;
  final String refreshToken;
  final int refreshTokenExpiresAt;

  const SignupApiResponse({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory SignupApiResponse.fromJson(Map<String, dynamic> json) {
    return SignupApiResponse(
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] as int,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] as int,
    );
  }
}
