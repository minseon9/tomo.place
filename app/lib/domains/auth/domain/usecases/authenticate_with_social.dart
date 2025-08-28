import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../entities/social_account.dart';

/// 소셜 계정으로 사용자 인증 UseCase
/// 
/// 비즈니스 로직을 캡슐화한 UseCase 클래스입니다.
/// 단일 책임 원칙에 따라 오직 소셜 인증 로직만 담당합니다.
class AuthenticateWithSocialUseCase {
  const AuthenticateWithSocialUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// 소셜 계정 정보로 사용자 인증 실행
  /// 
  /// [socialAccount] 소셜 로그인으로부터 받은 계정 정보
  /// 
  /// Returns: 인증된 사용자 정보
  /// Throws: [AuthException] 인증 실패 시
  /// Throws: [SocialAuthValidationException] 소셜 계정 정보가 유효하지 않을 시
  Future<User> call(SocialAccount socialAccount) async {
    // 비즈니스 규칙 검증
    _validateSocialAccount(socialAccount);

    try {
      // Repository를 통한 인증 수행
      final user = await _authRepository.authenticateWithSocial(socialAccount);
      
      // 인증 후 추가 비즈니스 로직이 필요한 경우 여기에 구현
      _logAuthenticationEvent(user, socialAccount);
      
      return user;
    } on AuthException {
      // AuthException은 그대로 전파
      rethrow;
    } catch (e) {
      // 기타 예외를 AuthException으로 래핑
      throw AuthException('소셜 인증 중 예상치 못한 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 소셜 계정 정보 유효성 검증
  void _validateSocialAccount(SocialAccount socialAccount) {
    if (socialAccount.provider.isEmpty) {
      throw const SocialAuthValidationException('소셜 제공자 정보가 없습니다.');
    }

    if (socialAccount.providerUserId.isEmpty) {
      throw const SocialAuthValidationException('소셜 제공자 사용자 ID가 없습니다.');
    }

    if (socialAccount.accessToken.isEmpty) {
      throw const SocialAuthValidationException('접근 토큰이 없습니다.');
    }

    // 토큰 만료 검증
    if (socialAccount.isTokenExpired) {
      throw const SocialAuthValidationException('소셜 로그인 토큰이 만료되었습니다.');
    }

    // 제공자별 추가 검증
    _validateByProvider(socialAccount);
  }

  /// 제공자별 특별한 검증 로직
  void _validateByProvider(SocialAccount socialAccount) {
    switch (socialAccount.provider.toLowerCase()) {
      case 'kakao':
        // 카카오는 이메일이 선택사항이므로 검증하지 않음
        break;
      case 'google':
        // 구글은 이메일이 필수
        if (!socialAccount.hasEmail) {
          throw const SocialAuthValidationException('구글 로그인에는 이메일이 필요합니다.');
        }
        break;
      case 'apple':
        // 애플은 이메일 숨김 옵션이 있으므로 검증하지 않음
        break;
      default:
        throw SocialAuthValidationException('지원하지 않는 소셜 제공자입니다: ${socialAccount.provider}');
    }
  }

  /// 인증 이벤트 로깅 (분석/모니터링 목적)
  void _logAuthenticationEvent(User user, SocialAccount socialAccount) {
    // TODO: 분석 서비스에 로그인 이벤트 전송
    // 예: Firebase Analytics, Mixpanel 등
    // TODO: replace with domain logger if needed
  }
}

/// 소셜 인증 검증 예외 클래스
class SocialAuthValidationException implements Exception {
  const SocialAuthValidationException(this.message);

  final String message;

  @override
  String toString() => 'SocialAuthValidationException: $message';
}
