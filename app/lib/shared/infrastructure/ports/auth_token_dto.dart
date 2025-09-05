class AuthTokenDto {
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String tokenType;
  
  const AuthTokenDto({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    this.tokenType = 'Bearer',
  });

  String get authorizationHeader => '$tokenType $accessToken';
}
