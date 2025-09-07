import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Config 관련 Mock 클래스들
class MockDotEnv extends Mock implements DotEnv {}

/// Config Mock 객체 생성을 위한 팩토리 클래스
class ConfigMockFactory {
  ConfigMockFactory._();

  /// Mock DotEnv 생성
  static MockDotEnv createDotEnv() => MockDotEnv();

  /// 테스트용 환경 변수 맵 생성
  static Map<String, String> createTestEnvVars({
    String apiUrl = 'https://api.test.com',
    String androidGoogleClientId = 'android_client_id',
    String iosGoogleClientId = 'ios_client_id',
    String googleServerClientId = 'server_client_id',
    String googleRedirectUri = 'https://test.com/auth/google',
    String? appleClientId,
    String? appleTeamId,
    String? appleKeyId,
    String? appleRedirectUri,
    String? kakaoClientId,
    String? kakaoJavascriptKey,
    String? kakaoRedirectUri,
  }) {
    final envVars = <String, String>{
      'API_URL': apiUrl,
      'ANDROID_GOOGLE_CLIENT_ID': androidGoogleClientId,
      'IOS_GOOGLE_CLIENT_ID': iosGoogleClientId,
      'GOOGLE_SERVER_CLIENT_ID': googleServerClientId,
      'GOOGLE_REDIRECT_URI': googleRedirectUri,
    };

    // 선택적 환경 변수들
    if (appleClientId != null) envVars['APPLE_CLIENT_ID'] = appleClientId;
    if (appleTeamId != null) envVars['APPLE_TEAM_ID'] = appleTeamId;
    if (appleKeyId != null) envVars['APPLE_KEY_ID'] = appleKeyId;
    if (appleRedirectUri != null) envVars['APPLE_REDIRECT_URI'] = appleRedirectUri;
    if (kakaoClientId != null) envVars['KAKAO_CLIENT_ID'] = kakaoClientId;
    if (kakaoJavascriptKey != null) envVars['KAKAO_JAVASCRIPT_KEY'] = kakaoJavascriptKey;
    if (kakaoRedirectUri != null) envVars['KAKAO_REDIRECT_URI'] = kakaoRedirectUri;

    return envVars;
  }

  /// 필수 환경 변수가 누락된 테스트용 환경 변수 맵 생성
  static Map<String, String> createIncompleteEnvVars({
    List<String> missingVars = const [],
  }) {
    final envVars = createTestEnvVars();
    
    // 누락된 변수들 제거
    for (final varName in missingVars) {
      envVars.remove(varName);
    }
    
    return envVars;
  }

  /// 빈 환경 변수 맵 생성
  static Map<String, String> createEmptyEnvVars() => <String, String>{};
}
