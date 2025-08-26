import '../entities/social_account.dart';
import '../repositories/social_auth_repository.dart';

/// 구글 로그인 UseCase
/// 
/// 구글 소셜 로그인 비즈니스 로직을 캡슐화합니다.
/// 단일 책임 원칙에 따라 오직 구글 로그인만 담당합니다.
class GoogleLoginUseCase {
  const GoogleLoginUseCase(this._socialAuthRepository);

  final SocialAuthRepository _socialAuthRepository;

  /// 구글 로그인 실행
  /// 
  /// Returns: 구글 계정 정보
  /// Throws: [SocialLoginException] 로그인 실패 시
  /// Throws: [GoogleLoginException] 구글 특화 오류 시
  Future<SocialAccount> call() async {
    try {
      // 구글 로그인 가능 여부 확인
      final isAvailable = await _socialAuthRepository.isAvailable('google');
      if (!isAvailable) {
        throw const GoogleLoginException('구글 로그인을 사용할 수 없습니다. Google Play 서비스를 확인해주세요.');
      }

      // 구글 로그인 실행
      final socialAccount = await _socialAuthRepository.loginWithGoogle();
      
      // 구글 특화 비즈니스 로직
      _validateGoogleAccount(socialAccount);
      
      // 로그인 성공 이벤트 로깅
      _logGoogleLoginSuccess(socialAccount);
      
      return socialAccount;
    } on SocialLoginException {
      // SocialLoginException은 그대로 전파
      rethrow;
    } on GoogleLoginException {
      // GoogleLoginException도 그대로 전파
      rethrow;
    } catch (e) {
      // 기타 예외를 GoogleLoginException으로 래핑
      throw GoogleLoginException('구글 로그인 중 예상치 못한 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 구글 계정 정보 검증
  void _validateGoogleAccount(SocialAccount account) {
    if (account.provider != 'google') {
      throw GoogleLoginException('잘못된 제공자 정보입니다: ${account.provider}');
    }

    // 구글은 이메일이 필수
    if (!account.hasEmail) {
      throw const GoogleLoginException('구글 로그인에는 이메일 권한이 필요합니다.');
    }

    // 사용자 ID 검증
    if (account.providerUserId.isEmpty) {
      throw const GoogleLoginException('구글 사용자 ID를 가져올 수 없습니다.');
    }

    // 이메일 형식 검증
    if (!_isValidEmail(account.email!)) {
      throw GoogleLoginException('유효하지 않은 이메일 형식입니다: ${account.email}');
    }
  }

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 구글 로그인 성공 이벤트 로깅
  void _logGoogleLoginSuccess(SocialAccount account) {
    // TODO: 분석 서비스에 구글 로그인 이벤트 전송
    print('Google login success: ${account.email}');
  }
}

/// 구글 로그인 특화 예외 클래스
class GoogleLoginException implements Exception {
  const GoogleLoginException(this.message);

  final String message;

  @override
  String toString() => 'GoogleLoginException: $message';
}
