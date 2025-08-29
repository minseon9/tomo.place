import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;

/// Google Sign-In 테스트 페이지
/// 
/// Google Sign-In SDK 동작을 확인하기 위한 테스트 페이지입니다.
/// try-catch로 오류를 안전하게 처리합니다.
class GoogleAuthTestPage extends StatefulWidget {
  const GoogleAuthTestPage({super.key});

  @override
  State<GoogleAuthTestPage> createState() => _GoogleAuthTestPageState();
}

class _GoogleAuthTestPageState extends State<GoogleAuthTestPage> {
  String _status = '테스트 페이지 로드됨';
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('GoogleAuthTestPage 초기화됨');
    _checkSignInStatus();
  }

  /// Google Sign-In 인스턴스 생성 (안전한 방법)
  GoogleSignIn _createGoogleSignIn() {
    try {
      // 기본 설정으로 시도
      return GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    } catch (e) {
      print('Google Sign-In 초기화 오류: $e');
      throw Exception('Google Sign-In 초기화 실패: $e');
    }
  }

  /// 현재 로그인 상태 확인
  Future<void> _checkSignInStatus() async {
    try {
      setState(() {
        _status = '로그인 상태 확인 중...';
        _isLoading = true;
      });

      print('로그인 상태 확인 시작');
      
      final googleSignIn = _createGoogleSignIn();

      final isSignedIn = await googleSignIn.isSignedIn();
      print('로그인 상태: $isSignedIn');

      if (isSignedIn) {
        final user = await googleSignIn.currentUser;
        print('현재 사용자: ${user?.email}');
        
        setState(() {
          _currentUser = user;
          _status = '이미 로그인되어 있습니다.\n이메일: ${user?.email}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = '로그인되지 않았습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('로그인 상태 확인 오류: $e');
      setState(() {
        _status = '로그인 상태 확인 실패: $e';
        _isLoading = false;
      });
    }
  }

  /// Google Sign-In 실행
  Future<void> _signIn() async {
    try {
      setState(() {
        _status = 'Google 로그인 시도 중...';
        _isLoading = true;
      });

      print('Google Sign-In 시작');
      
      final googleSignIn = _createGoogleSignIn();

      final account = await googleSignIn.signIn();
      print('Sign-In 결과: ${account?.email}');

      if (account == null) {
        setState(() {
          _status = '사용자가 로그인을 취소했습니다.';
          _isLoading = false;
        });
        return;
      }

      // 인증 정보 가져오기
      final auth = await account.authentication;
      print('인증 토큰: ${auth.accessToken != null ? '있음' : '없음'}');
      print('ID 토큰: ${auth.idToken != null ? '있음' : '없음'}');

      setState(() {
        _currentUser = account;
        _status = '로그인 성공!\n이메일: ${account.email}\n이름: ${account.displayName ?? 'N/A'}\nID: ${account.id}';
        _isLoading = false;
      });

      // 서버에 전달할 정보 출력
      final userInfo = {
        'id': account.id,
        'email': account.email,
        'displayName': account.displayName,
        'photoUrl': account.photoUrl,
        'serverAuthCode': auth.serverAuthCode,
        'accessToken': auth.accessToken,
        'idToken': auth.idToken,
      };
      
      print('서버에 전달할 정보: $userInfo');

    } catch (e) {
      print('Google Sign-In 오류: $e');
      setState(() {
        _status = '로그인 실패: $e';
        _isLoading = false;
      });
    }
  }

  /// 로그아웃
  Future<void> _signOut() async {
    try {
      setState(() {
        _status = '로그아웃 중...';
        _isLoading = true;
      });

      print('Google Sign-Out 시작');
      
      final googleSignIn = _createGoogleSignIn();
      await googleSignIn.signOut();

      setState(() {
        _currentUser = null;
        _status = '로그아웃 완료';
        _isLoading = false;
      });

      print('Google Sign-Out 완료');

    } catch (e) {
      print('Google Sign-Out 오류: $e');
      setState(() {
        _status = '로그아웃 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '현재 상태:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 사용자 정보 표시
            if (_currentUser != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '사용자 정보:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('이메일: ${_currentUser!.email}'),
                      Text('이름: ${_currentUser!.displayName ?? 'N/A'}'),
                      Text('ID: ${_currentUser!.id}'),
                      if (_currentUser!.photoUrl != null)
                        Text('프로필 사진: 있음'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 버튼들
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Google 로그인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading || _currentUser == null ? null : _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkSignInStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('상태 새로고침'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: () {
                print('뒤로가기 버튼 클릭');
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('뒤로가기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
