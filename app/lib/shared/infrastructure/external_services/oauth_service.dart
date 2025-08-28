import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/oauth_config.dart';
import '../../utils/global_context.dart';
import 'oauth_webview.dart';

/// OAuth 서비스 추상 클래스
/// 
/// 다양한 OAuth Provider를 지원하기 위한 확장 가능한 인터페이스입니다.
abstract class OAuthService {
  /// OAuth 인증 플로우 실행
  /// 
  /// [provider] OAuth Provider (예: 'GOOGLE', 'KAKAO', 'APPLE')
  /// Returns: 인증 코드 (authorization code)
  Future<String> authenticate(String provider);
  
  /// State 생성 (CSRF 방지)
  String generateState();
  
  /// 인증 URL 생성
  String buildAuthUrl(String provider, String state);
  
  /// 인증 플로우 실행 (WebView)
  Future<String> launchAuthFlow(String authUrl, String expectedState);
}

/// OAuth 서비스 구현체
class OAuthServiceImpl implements OAuthService {
  @override
  Future<String> authenticate(String provider) async {
    try {
      // 1. State 생성 (CSRF 방지)
      final state = generateState();
      
      // 2. OAuth URL 생성
      final authUrl = buildAuthUrl(provider, state);
      
      // 3. WebView로 인증 플로우 실행
      final authCode = await launchAuthFlow(authUrl, state);
      
      return authCode;
    } catch (e) {
      throw OAuthException('OAuth 인증에 실패했습니다: ${e.toString()}');
    }
  }
  
  @override
  String generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
  
  @override
  String buildAuthUrl(String provider, String state) {
    final config = OAuthConfig.getProviderConfig(provider);
    if (config == null) {
      throw OAuthException('지원하지 않는 OAuth Provider입니다: $provider');
    }
    
    return config.buildAuthUrl(state);
  }
  
  @override
  Future<String> launchAuthFlow(String authUrl, String expectedState) async {
    final completer = Completer<String>();
    
    // WebView 페이지로 이동
    await Navigator.of(_getGlobalContext()).push(
      MaterialPageRoute(
        builder: (context) => OAuthWebView(
          authUrl: authUrl,
          expectedState: expectedState,
          onSuccess: (authCode) {
            Navigator.of(context).pop();
            completer.complete(authCode);
          },
          onError: (error) {
            Navigator.of(context).pop();
            completer.completeError(OAuthException(error));
          },
        ),
      ),
    );
    
    return completer.future;
  }
  
  /// 전역 컨텍스트 가져오기
  BuildContext _getGlobalContext() {
    return GlobalContext.context;
  }
}

/// OAuth 예외 클래스
class OAuthException implements Exception {
  final String message;
  
  const OAuthException(this.message);
  
  @override
  String toString() => 'OAuthException: $message';
}
