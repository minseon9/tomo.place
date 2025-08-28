/// 인증 관련 예외 클래스
class AuthException implements Exception {
  final String message;
  final String? code;
  
  const AuthException(this.message, {this.code});
  
  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
