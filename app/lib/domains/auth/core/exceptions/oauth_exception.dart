import '../../../../shared/error_handling/models/exception_interface.dart';
import 'error_codes.dart';
import 'error_types.dart';

class OAuthException implements ExceptionInterface {
  @override
  final String message;

  @override
  final String userMessage;

  @override
  final String title;

  @override
  final String? errorCode;

  @override
  final String errorType;

  @override
  final String? suggestedAction;

  final String? provider;

  const OAuthException({
    required this.message,
    required this.userMessage,
    required this.title,
    required this.errorType,
    this.errorCode,
    this.suggestedAction,
    this.provider,
  });

  /// 로그아웃 실패
  factory OAuthException.signOutFailed({
    required String message,
    String? provider,
  }) {
    return OAuthException(
      message: 'OAuth sign out exception raised: $message',
      userMessage: '로그아웃이 실패했습니다.',
      title: '로그아웃 오류',
      errorType: AuthErrorTypes.oauth,
      errorCode: AuthErrorCodes.oauthSignOutFailed,
      suggestedAction: '다시 시도해주세요.',
      provider: provider,
    );
  }

  /// 인증 실패
  factory OAuthException.authenticationFailed({
    required String message,
    String? provider,
  }) {
    return OAuthException(
      message: 'OAuth exception raised: $message',
      userMessage: '인증이 실패했습니다.',
      title: '인증 오류',
      errorType: AuthErrorTypes.oauth,
      errorCode: AuthErrorCodes.oauthAuthenticationFailed,
      suggestedAction: '다시 로그인해주세요.',
      provider: provider,
    );
  }

  /// 토큰 갱신 실패
  factory OAuthException.tokenRefreshFailed({
    required String message,
    String? provider,
  }) {
    return OAuthException(
      message: 'Token refresh failed: $message',
      userMessage: '토큰 갱신에 실패했습니다.',
      title: '토큰 오류',
      errorType: AuthErrorTypes.token,
      errorCode: AuthErrorCodes.tokenRefreshFailed,
      suggestedAction: '다시 로그인해주세요.',
      provider: provider,
    );
  }

  /// 제공자 오류
  factory OAuthException.providerError({
    required String message,
    String? provider,
  }) {
    return OAuthException(
      message: 'OAuth provider error: $message',
      userMessage: '로그인 제공자에서 오류가 발생했습니다.',
      title: '제공자 오류',
      errorType: AuthErrorTypes.provider,
      errorCode: AuthErrorCodes.oauthProviderError,
      suggestedAction: '다른 방법으로 로그인하거나 잠시 후 다시 시도해주세요.',
      provider: provider,
    );
  }

  /// 잘못된 응답
  factory OAuthException.invalidResponse({
    required String message,
    String? provider,
  }) {
    return OAuthException(
      message: 'Invalid OAuth response: $message',
      userMessage: '로그인 응답을 처리할 수 없습니다.',
      title: '응답 오류',
      errorType: AuthErrorTypes.oauth,
      errorCode: AuthErrorCodes.oauthInvalidResponse,
      suggestedAction: '다시 시도해주세요.',
      provider: provider,
    );
  }

  /// 네트워크 오류
  factory OAuthException.networkError({
    required String message,
    String? provider,
  }) {
    return OAuthException(
      message: 'OAuth network error: $message',
      userMessage: '네트워크 오류로 로그인할 수 없습니다.',
      title: '네트워크 오류',
      errorType: AuthErrorTypes.oauth,
      errorCode: AuthErrorCodes.oauthNetworkError,
      suggestedAction: '네트워크 연결을 확인하고 다시 시도해주세요.',
      provider: provider,
    );
  }

  @override
  String toString() {
    return 'OAuthException(message: $message, provider: $provider, errorCode: $errorCode)';
  }
}
