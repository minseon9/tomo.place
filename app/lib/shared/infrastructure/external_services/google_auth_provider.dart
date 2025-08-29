import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In Provider
/// 
/// Google Sign-In SDK를 사용하여 Google OAuth 인증을 처리합니다.
class GoogleAuthProvider {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Google Sign-In 실행
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      throw Exception('Google Sign-In 실패: $error');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      throw Exception('Google Sign-Out 실패: $error');
    }
  }

  /// 현재 로그인된 사용자 정보 조회
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (error) {
      throw Exception('현재 사용자 정보 조회 실패: $error');
    }
  }

  /// 인증 상태 확인
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      throw Exception('인증 상태 확인 실패: $error');
    }
  }

  /// 인증 토큰 가져오기
  Future<GoogleSignInAuthentication?> getAuthToken() async {
    try {
      final GoogleSignInAccount? account = await getCurrentUser();
      if (account != null) {
        return await account.authentication;
      }
      return null;
    } catch (error) {
      throw Exception('인증 토큰 가져오기 실패: $error');
    }
  }
}
