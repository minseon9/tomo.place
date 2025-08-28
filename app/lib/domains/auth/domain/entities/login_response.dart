/// 로그인 응답 모델
/// 
/// 서버의 `/api/oidc/login` 또는 `/api/oidc/signup` 엔드포인트로부터 받는 응답 데이터입니다.
/// access token과 refresh token을 포함합니다.
class LoginResponse {
  final String token;
  final String refreshToken;
  
  const LoginResponse({
    required this.token,
    required this.refreshToken,
  });
  
  /// JSON 역직렬화
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
  };
  
  @override
  String toString() => 'LoginResponse(token: ${token.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}...)';
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LoginResponse &&
    runtimeType == other.runtimeType &&
    token == other.token &&
    refreshToken == other.refreshToken;

  @override
  int get hashCode => token.hashCode ^ refreshToken.hashCode;
}
