import 'package:google_sign_in/google_sign_in.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';

import '../../../core/exceptions/oauth_exception.dart';
import '../config/google_oauth_config.dart';
import '../oauth_service.dart';
import '../oauth_result.dart';

class GoogleAuthService implements OAuthService<GoogleOAuthConfig> {
  final GoogleOAuthConfig _config;
  
  GoogleAuthService(this._config);
  
  @override
  GoogleOAuthConfig get config => _config;
  
  static bool _isInitialized = false;

  static Future<void> _ensureInitialized(GoogleOAuthConfig config) async {
    if (_isInitialized) return;

    await GoogleSignIn.instance.initialize(
      clientId: config.clientId,
      serverClientId: config.serverClientId,
    );

    _isInitialized = true;
  }

  @override
  String get providerId => SocialProvider.google.code;
  
  @override
  String get displayName => 'Google';

  // Android와 iOS 모두 지원
  @override
  bool get isSupported => true;

  @override
  Future<OAuthResult> signIn() async {
    try {
      await _ensureInitialized(_config);

      final scopes = _config.scope;
      final GoogleSignInServerAuthorization? serverAuth = await GoogleSignIn
          .instance
          .authorizationClient
          .authorizeServer(scopes);

      final String? authorizationCode = serverAuth?.serverAuthCode;
      if (authorizationCode == null) {
        return OAuthResult.failure(
          error: 'Authorization Code를 받지 못했습니다.',
          errorCode: 'NO_AUTH_CODE',
        );
      }

      return OAuthResult.success(authorizationCode: authorizationCode);
    } catch (error) {
      if (error is GoogleSignInException &&
          error.code == GoogleSignInExceptionCode.canceled) {
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
      await _ensureInitialized(_config);
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
    await _ensureInitialized(_config);
  }

  @override
  Future<void> dispose() async {
    // 별도 dispose 필요 없음 (이벤트 스트림은 앱 종료 시 정리)
  }
}
