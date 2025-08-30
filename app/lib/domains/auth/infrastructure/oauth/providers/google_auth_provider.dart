import 'package:google_sign_in/google_sign_in.dart';
import '../../../../../shared/config/oauth_config.dart';
import '../oauth_provider.dart';
import '../../../../../shared/exceptions/oauth_result.dart';
import '../../../../../shared/exceptions/oauth_exception.dart';

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
      // FIXME: canceled 외에는 error를 그대로 받아서 처리하도록 수정
      if (error is GoogleSignInException && error.code == GoogleSignInExceptionCode.canceled) {
        // 사용자 취소는 exception이 아닌 정상적인 결과로 처리
        return OAuthResult.cancelled();
      }

      throw OAuthException.authenticationFailed(
        message: error.toString(),
        provider: providerId,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();

      await GoogleSignIn.instance.signOut();
    } catch (error) {
      throw OAuthException.signOutFailed(
        message: error.toString(),
        provider: providerId,
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
