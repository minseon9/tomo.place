import 'package:google_sign_in/google_sign_in.dart';
import 'google_auth_provider.dart';

/// OAuth 인증 서비스 (Google Sign-In SDK 기반)
/// 
/// Google Sign-In SDK를 사용하여 OAuth 인증을 처리합니다.
/// 기존 WebView 기반 OAuth를 대체합니다.
class OAuthServiceNew {
  final GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();

  /// Google OAuth 인증 실행
  /// 
  /// Google Sign-In SDK를 사용하여 인증을 수행하고,
  /// 인증 코드를 서버에 전달하여 토큰을 받습니다.
  Future<Map<String, dynamic>> authenticateWithGoogle() async {
    try {
      // 1. Google Sign-In 실행
      final GoogleSignInAccount? account = await _googleAuthProvider.signIn();
      
      if (account == null) {
        throw Exception('사용자가 로그인을 취소했습니다.');
      }

      // 2. 인증 토큰 가져오기
      final GoogleSignInAuthentication auth = await account.authentication;
      
      // 3. 사용자 정보 구성
      final userInfo = {
        'id': account.id,
        'email': account.email,
        'displayName': account.displayName,
        'photoUrl': account.photoUrl,
        'serverAuthCode': auth.serverAuthCode,
        'accessToken': auth.accessToken,
        'idToken': auth.idToken,
      };

      return userInfo;
    } catch (error) {
      throw Exception('Google OAuth 인증 실패: $error');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _googleAuthProvider.signOut();
    } catch (error) {
      throw Exception('로그아웃 실패: $error');
    }
  }

  /// 현재 인증 상태 확인
  Future<bool> isSignedIn() async {
    try {
      return await _googleAuthProvider.isSignedIn();
    } catch (error) {
      throw Exception('인증 상태 확인 실패: $error');
    }
  }

  /// 현재 사용자 정보 조회
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleAuthProvider.getCurrentUser();
    } catch (error) {
      throw Exception('사용자 정보 조회 실패: $error');
    }
  }
}
