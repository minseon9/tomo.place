import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 설정 관리 클래스
/// 
/// 환경별 설정을 관리하며, 런타임에 설정을 업데이트할 수 있습니다.
/// 보안이 중요한 설정은 서버에서 동적으로 제공받습니다.
class AppConfig {
  static const String _configKey = 'app_config';
  
  // 기본값 (개발 환경)
  static const String _defaultApiUrl = 'http://127.0.0.1:8080';
  static const String _defaultOAuthRedirectUri = 'http://localhost:8080/api/auth/social-login';
  
  // 런타임 설정 (서버에서 업데이트 가능)
  static String? _apiUrl;
  static String? _oauthClientId;
  static String? _oauthRedirectUri;
  
  /// 초기화
  static Future<void> initialize() async {
    // 1. 로컬 저장소에서 설정 로드
    await _loadFromLocal();
    
    // 2. 서버에서 최신 설정 가져오기 (선택적)
    await _loadFromServer();
  }
  
  /// 로컬 저장소에서 설정 로드
  static Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);
      
      if (configJson != null) {
        final config = jsonDecode(configJson) as Map<String, dynamic>;
        _apiUrl = config['api_url'] as String?;
        _oauthClientId = config['oauth_client_id'] as String?;
        _oauthRedirectUri = config['oauth_redirect_uri'] as String?;
      }
    } catch (e) {
      // 로컬 설정 로드 실패 시 기본값 사용
      print('로컬 설정 로드 실패: $e');
    }
  }
  
  /// 서버에서 설정 로드 (선택적)
  static Future<void> _loadFromServer() async {
    try {
      // TODO: 서버에서 설정 API 호출
      // final response = await http.get('${_apiUrl}/api/config');
      // final config = jsonDecode(response.body);
      // await _saveToLocal(config);
    } catch (e) {
      // 서버 설정 로드 실패 시 로컬 설정 유지
      print('서버 설정 로드 실패: $e');
    }
  }
  
  /// 로컬에 설정 저장
  static Future<void> _saveToLocal(Map<String, dynamic> config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, jsonEncode(config));
    } catch (e) {
      print('설정 저장 실패: $e');
    }
  }
  
  /// API URL 조회
  static String get apiUrl => _apiUrl ?? _defaultApiUrl;
  
  /// OAuth Client ID 조회
  static String? get oauthClientId => _oauthClientId;
  
  /// OAuth Redirect URI 조회
  static String get oauthRedirectUri => _oauthRedirectUri ?? _defaultOAuthRedirectUri;
  
  /// 설정 업데이트
  static Future<void> updateConfig({
    String? apiUrl,
    String? oauthClientId,
    String? oauthRedirectUri,
  }) async {
    if (apiUrl != null) _apiUrl = apiUrl;
    if (oauthClientId != null) _oauthClientId = oauthClientId;
    if (oauthRedirectUri != null) _oauthRedirectUri = oauthRedirectUri;
    
    // 로컬에 저장
    await _saveToLocal({
      'api_url': _apiUrl,
      'oauth_client_id': _oauthClientId,
      'oauth_redirect_uri': _oauthRedirectUri,
    });
  }
}
