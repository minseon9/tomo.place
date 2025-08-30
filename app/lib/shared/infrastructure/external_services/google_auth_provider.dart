import 'package:google_sign_in/google_sign_in.dart';
import 'package:app/shared/config/oauth_config.dart';
import 'oauth_provider.dart';
import 'oauth_models.dart';
import '../../exceptions/oauth_exception.dart';

class GoogleAuthProvider implements OAuthProvider {
  static bool _isInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    // FIXME: serverClientId, clientId 모두 config를 통해 가져오도록(6버전에서는 ios, android에 각각 추가해줘야했음)
    final googleConfig = OAuthConfig.getProviderConfig('GOOGLE');
    final String serverClientId = "1016804314663-ji2taqsu14c3sqfg0u60jfni9shg3dja.apps.googleusercontent.com";

    await GoogleSignIn.instance.initialize(
      clientId: "1016804314663-31vke1m4f00tspni83e19cghoed4j4ns.apps.googleusercontent.com",
      serverClientId: serverClientId,
    );

    _isInitialized = true;
  }

  @override
  String get providerId => 'google';

  @override
  String get displayName => 'Google';

  // Android와 iOS 모두 지원
  @override
  bool get isSupported => true;

  @override
  Future<OAuthResult> signIn() async {
    try {
      await _ensureInitialized();

      final GoogleSignInServerAuthorization? serverAuth =
          await GoogleSignIn.instance.authorizationClient.authorizeServer(
        const <String>['email', 'profile'],
      );

      final String? authorizationCode = serverAuth?.serverAuthCode;
      if (authorizationCode == null) {
        return OAuthResult.failure(
          error: 'Authorization Code를 받지 못했습니다.',
          errorCode: 'NO_AUTH_CODE',
        );
      }

      return OAuthResult.success(
        authorizationCode: authorizationCode,
      );
    } catch (error) {
      // GoogleSignInException 타입 체크 및 코드 기반 분기 처리
      if (error is GoogleSignInException) {
        switch (error.code) {
          case GoogleSignInExceptionCode.cancelled:
            // 사용자 취소는 exception이 아닌 정상적인 결과로 처리
            return OAuthResult.cancelled();
          case GoogleSignInExceptionCode.networkError:
            throw OAuthException.networkError(
              message: 'Google Sign-In network error: ${error.message}',
              provider: providerId,
              originalError: error,
            );
          case GoogleSignInExceptionCode.signInRequired:
            throw OAuthException.authenticationFailed(
              message: 'Google Sign-In required: ${error.message}',
              provider: providerId,
              errorCode: error.code.name,
              originalError: error,
            );
          case GoogleSignInExceptionCode.apiNotConnected:
            throw OAuthException.serverError(
              message: 'Google API not connected: ${error.message}',
              provider: providerId,
              errorCode: error.code.name,
              originalError: error,
            );
          default:
            throw OAuthException.unknown(
              message: 'Google Sign-In failed: ${error.message}',
              provider: providerId,
              originalError: error,
            );
        }
      } else {
        // GoogleSignInException이 아닌 다른 에러
        throw OAuthException.unknown(
          message: 'Google OIDC Sign-In 실패: $error',
          provider: providerId,
          originalError: error,
        );
      }
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();

      await GoogleSignIn.instance.signOut();
      
      // TODO: 공통 로깅 시스템으로 이동
      print('Google Sign-Out 성공');
    } catch (error) {
      // TODO: 공통 에러 처리 로직으로 이동
      print('Google Sign-Out 실패: $error');
      throw OAuthException.unknown(
        message: 'Google Sign-Out 실패: $error',
        provider: providerId,
        originalError: error,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.disconnect();
    } catch (error) {
      throw OAuthException.unknown(
        message: 'Google 계정 연결 해제 실패: $error',
        provider: providerId,
        originalError: error,
      );
    }
  }

  @override
  Future<void> initialize() async {
    await _ensureInitialized();
  }

  @override
  Future<void> dispose() async {
    // 별도 dispose 필요 없음 (이벤트 스트림은 앱 종료 시 정리)
  }
}
