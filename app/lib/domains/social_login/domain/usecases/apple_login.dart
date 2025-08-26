import '../entities/social_account.dart';
import '../repositories/social_auth_repository.dart';

/// 애플 로그인 UseCase
/// 
/// 애플 소셜 로그인 비즈니스 로직을 캡슐화합니다.
/// 단일 책임 원칙에 따라 오직 애플 로그인만 담당합니다.
class AppleLoginUseCase {
  const AppleLoginUseCase(this._socialAuthRepository);

  final SocialAuthRepository _socialAuthRepository;

  /// 애플 로그인 실행
  /// 
  /// Returns: 애플 계정 정보
  /// Throws: [SocialLoginException] 로그인 실패 시
  /// Throws: [AppleLoginException] 애플 특화 오류 시
  Future<SocialAccount> call() async {
    try {
      // 애플 로그인 가능 여부 확인
      final isAvailable = await _socialAuthRepository.isAvailable('apple');
      if (!isAvailable) {
        throw const AppleLoginException('애플 로그인을 사용할 수 없습니다. iOS 13.0 이상에서만 지원됩니다.');
      }

      // 애플 로그인 실행
      final socialAccount = await _socialAuthRepository.loginWithApple();
      
      // 애플 특화 비즈니스 로직
      _validateAppleAccount(socialAccount);
      
      // 로그인 성공 이벤트 로깅
      _logAppleLoginSuccess(socialAccount);
      
      return socialAccount;
    } on SocialLoginException {
      // SocialLoginException은 그대로 전파
      rethrow;
    } on AppleLoginException {
      // AppleLoginException도 그대로 전파
      rethrow;
    } catch (e) {
      // 기타 예외를 AppleLoginException으로 래핑
      throw AppleLoginException('애플 로그인 중 예상치 못한 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 애플 계정 정보 검증
  void _validateAppleAccount(SocialAccount account) {
    if (account.provider != 'apple') {
      throw AppleLoginException('잘못된 제공자 정보입니다: ${account.provider}');
    }

    // 사용자 ID 검증 (애플에서는 필수)
    if (account.providerUserId.isEmpty) {
      throw const AppleLoginException('애플 사용자 ID를 가져올 수 없습니다.');
    }

    // 애플은 이메일 숨김 옵션이 있으므로 이메일이 없을 수 있음
    // 하지만 있는 경우 형식을 검증
    if (account.hasEmail && !_isValidEmail(account.email!)) {
      throw AppleLoginException('유효하지 않은 이메일 형식입니다: ${account.email}');
    }

    // Identity Token 검증 (애플의 경우 accessToken이 실제로는 identityToken)
    if (account.accessToken.isEmpty) {
      throw const AppleLoginException('애플 Identity Token을 가져올 수 없습니다.');
    }
  }

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 애플 로그인 성공 이벤트 로깅
  void _logAppleLoginSuccess(SocialAccount account) {
    // TODO: 분석 서비스에 애플 로그인 이벤트 전송
    // 애플의 경우 개인정보 보호를 위해 최소한의 정보만 로깅
    print('Apple login success: ${account.providerUserId}');
  }
}

/// 애플 로그인 특화 예외 클래스
class AppleLoginException implements Exception {
  const AppleLoginException(this.message);

  final String message;

  @override
  String toString() => 'AppleLoginException: $message';
}
