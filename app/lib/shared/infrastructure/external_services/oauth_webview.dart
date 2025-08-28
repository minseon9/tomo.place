import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// OAuth WebView 페이지
/// 
/// OAuth 인증 플로우를 위한 WebView 페이지입니다.
/// redirect_uri로 리다이렉트되면 인증 코드를 추출합니다.
class OAuthWebView extends StatefulWidget {
  final String authUrl;
  final String expectedState;
  final Function(String authCode) onSuccess;
  final Function(String error) onError;
  
  const OAuthWebView({
    super.key,
    required this.authUrl,
    required this.expectedState,
    required this.onSuccess,
    required this.onError,
  });
  
  @override
  State<OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<OAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // redirect_uri로 리다이렉트되는지 확인
            if (_isRedirectUrl(request.url)) {
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }
  
  /// redirect_uri인지 확인
  bool _isRedirectUrl(String url) {
    final redirectUri = 'http://localhost:8080/api/auth/social-login';
    return url.startsWith(redirectUri);
  }
  
  /// 리다이렉트 URL 처리
  void _handleRedirect(String url) {
    try {
      final uri = Uri.parse(url);
      final queryParams = uri.queryParameters;
      
      // 에러 확인
      if (queryParams.containsKey('error')) {
        final error = queryParams['error']!;
        final errorDescription = queryParams['error_description'] ?? '알 수 없는 오류';
        widget.onError('$error: $errorDescription');
        return;
      }
      
      // state 검증
      final state = queryParams['state'];
      if (state != widget.expectedState) {
        widget.onError('State 검증에 실패했습니다. CSRF 공격 가능성이 있습니다.');
        return;
      }
      
      // authorization code 추출
      final authCode = queryParams['code'];
      if (authCode == null || authCode.isEmpty) {
        widget.onError('인증 코드를 받지 못했습니다.');
        return;
      }
      
      // 성공 처리
      widget.onSuccess(authCode);
      
    } catch (e) {
      widget.onError('리다이렉트 처리 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소셜 로그인'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onError('사용자가 로그인을 취소했습니다.');
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
