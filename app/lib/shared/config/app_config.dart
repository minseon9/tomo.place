import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'env_config.dart';

/// 앱 설정 관리 클래스
/// 
/// 환경별 공통 설정을 관리하며, 런타임에 설정을 업데이트할 수 있습니다.
/// OAuth 관련 설정은 auth 도메인에서 별도로 관리합니다.
class AppConfig {
  static const String _configKey = 'app_config';
  
  // 런타임 설정 (서버에서 업데이트 가능)
  static String? _apiUrl;
  
  /// 초기화
  static Future<void> initialize() async {
    // 1. 환경 설정 로드 (.env 파일)
    await EnvConfig.initialize();
    
    // 2. 로컬 저장소에서 설정 로드
    await _loadFromLocal();
    
    // 3. 서버에서 최신 설정 가져오기 (선택적)
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
  /// 
  /// 우선순위: 런타임 설정 > .env 파일 > 기본값
  static String get apiUrl => _apiUrl ?? EnvConfig.apiUrl;
  
  /// 설정 업데이트
  static Future<void> updateConfig({
    String? apiUrl,
  }) async {
    if (apiUrl != null) _apiUrl = apiUrl;
    
    // 로컬에 저장
    await _saveToLocal({
      'api_url': _apiUrl,
    });
  }
}
