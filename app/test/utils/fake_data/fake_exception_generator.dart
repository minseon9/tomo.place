import 'package:faker/faker.dart';
import 'package:app/domains/auth/core/exceptions/auth_exception.dart';
import 'package:app/domains/auth/core/exceptions/oauth_exception.dart';

/// 테스트용 예외 생성 유틸리티
class FakeExceptionGenerator {
  /// AuthException 생성자들
  static AuthException createAuthenticationFailed() {
    return AuthException.authenticationFailed(
      message: faker.lorem.sentence(),
    );
  }

  static AuthException createTokenExpired() {
    return AuthException.tokenExpired(
      message: faker.lorem.sentence(),
    );
  }

  static AuthException createInvalidCredentials() {
    return AuthException.invalidCredentials(
      message: faker.lorem.sentence(),
    );
  }

  static AuthException createLogoutFailed() {
    return AuthException.authenticationFailed(
      message: faker.lorem.sentence(),
    );
  }

  /// OAuthException 생성자들
  static OAuthException createOAuthAuthenticationFailed() {
    return OAuthException.authenticationFailed(
      provider: faker.randomGenerator.element(['google', 'apple', 'kakao']),
      message: faker.lorem.sentence(),
    );
  }

  static OAuthException createOAuthNetworkError() {
    return OAuthException.networkError(
      provider: faker.randomGenerator.element(['google', 'apple', 'kakao']),
      message: faker.lorem.sentence(),
    );
  }

  /// 네트워크 에러 생성
  static AuthException createNetworkError() {
    return AuthException.authenticationFailed(
      message: '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.',
    );
  }

  /// 스토리지 에러 생성
  static AuthException createStorageError() {
    return AuthException.authenticationFailed(
      message: '로컬 저장소에 접근할 수 없습니다.',
    );
  }

  /// 서버 에러 생성
  static AuthException createServerError() {
    return AuthException.authenticationFailed(
      message: '서버에서 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
    );
  }
}
