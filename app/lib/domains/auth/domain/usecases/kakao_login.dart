import '../entities/social_account.dart';
import '../repositories/social_auth_repository.dart';

/// 카카오 로그인 UseCase
/// 
/// 카카오 소셜 로그인 비즈니스 로직을 캡슐화합니다.
/// 단일 책임 원칙에 따라 오직 카카오 로그인만 담당합니다.
class KakaoLoginUseCase {
  const KakaoLoginUseCase(this._socialAuthRepository);

  final SocialAuthRepository _socialAuthRepository;

  /// 카카오 로그인 실행
  /// 
  /// Returns: 카카오 계정 정보
  /// Throws: [SocialLoginException] 로그인 실패 시
  /// Throws: [KakaoLoginException] 카카오 특화 오류 시
  Future<SocialAccount> call() async {
    try {
      // 카카오 로그인 가능 여부 확인
      final isAvailable = await _socialAuthRepository.isAvailable('kakao');
      if (!isAvailable) {
        throw const KakaoLoginException('카카오 로그인을 사용할 수 없습니다. 카카오톡 앱을 설치해주세요.');
      }

      // 카카오 로그인 실행
      final socialAccount = await _socialAuthRepository.loginWithKakao();
      
      // 카카오 특화 비즈니스 로직
      _validateKakaoAccount(socialAccount);
      
      // 로그인 성공 이벤트 로깅
      _logKakaoLoginSuccess(socialAccount);
      
      return socialAccount;
    } on SocialLoginException {
      // SocialLoginException은 그대로 전파
      rethrow;
    } on KakaoLoginException {
      // KakaoLoginException도 그대로 전파
      rethrow;
    } catch (e) {
      // 기타 예외를 KakaoLoginException으로 래핑
      throw KakaoLoginException('카카오 로그인 중 예상치 못한 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 카카오 계정 정보 검증
  void _validateKakaoAccount(SocialAccount account) {
    if (account.provider != 'kakao') {
      throw KakaoLoginException('잘못된 제공자 정보입니다: ${account.provider}');
    }

    // 카카오는 이메일이 선택사항이므로 강제하지 않음
    // 하지만 사용자 ID는 필수
    if (account.providerUserId.isEmpty) {
      throw const KakaoLoginException('카카오 사용자 ID를 가져올 수 없습니다.');
    }
  }

  /// 카카오 로그인 성공 이벤트 로깅
  void _logKakaoLoginSuccess(SocialAccount account) {
    // TODO: 분석 서비스에 카카오 로그인 이벤트 전송
    // TODO: replace with domain logger if needed
  }
}

/// 카카오 로그인 특화 예외 클래스
class KakaoLoginException implements Exception {
  const KakaoLoginException(this.message);

  final String message;

  @override
  String toString() => 'KakaoLoginException: $message';
}
