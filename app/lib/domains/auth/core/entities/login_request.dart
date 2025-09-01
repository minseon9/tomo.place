/// 구글 로그인 요청 모델
/// 
/// 서버의 `/api/oidc/login` 엔드포인트에 전송할 요청 데이터입니다.
/// provider는 "GOOGLE"로 고정되며, authorizationCode는 구글 OAuth2 플로우에서 획득합니다.
class LoginRequest {
  final String provider; // "GOOGLE"
  final String authorizationCode;
  
  const LoginRequest({
    required this.provider,
    required this.authorizationCode,
  });
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() => {
    'provider': provider,
    'authorizationCode': authorizationCode,
  };
  
  @override
  String toString() => 'LoginRequest(provider: $provider, authorizationCode: $authorizationCode)';
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LoginRequest &&
    runtimeType == other.runtimeType &&
    provider == other.provider &&
    authorizationCode == other.authorizationCode;

  @override
  int get hashCode => provider.hashCode ^ authorizationCode.hashCode;
}
