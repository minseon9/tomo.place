import '../domain/repositories/auth_repository.dart';
import '../presentation/models/login_response.dart';
import '../../../../shared/infrastructure/storage/token_storage_service.dart';
import '../../../../shared/infrastructure/external_services/oauth_service.dart';

/// 인증 서비스
/// 
/// 비즈니스 로직을 담당하는 Service Layer입니다.
/// OAuth 플로우, 토큰 관리, 사용자 인증 등의 복잡한 로직을 처리합니다.
class AuthService {
  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  final OAuthService _oauthService;
  
  AuthService({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
    required OAuthService oauthService,
  }) : _repository = repository,
       _tokenStorage = tokenStorage,
       _oauthService = oauthService;
  
  /// 통합된 소셜 인증 실행
  /// 
  /// provider에 따라 적절한 OAuth 플로우를 실행하고 서버에 인증 요청을 보냅니다.
  /// OIDC 기반으로 로그인과 회원가입을 통합 처리합니다.
  /// 
  /// Returns: LoginResponse (토큰 포함)
  Future<LoginResponse> signupWithProvider(String provider) async {
    try {
      // 1. OAuth 플로우로 인증 코드 획득
      final authCode = await _oauthService.authenticate(provider.toUpperCase());
      
      // 2. 서버에 통합 인증 요청 (로그인/회원가입 자동 처리)
      final responseData = await _repository.authenticate(provider.toUpperCase(), authCode);
      
      // 3. LoginResponse 생성
      final loginResponse = LoginResponse.fromJson(responseData);
      
      // 4. 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: loginResponse.token,
        refreshToken: loginResponse.refreshToken,
      );
      
      return loginResponse;
    } catch (e) {
      throw AuthException('$provider 인증에 실패했습니다: ${e.toString()}');
    }
  }
  
  /// 로그아웃
  Future<void> logout() async {
    try {
      // 1. 서버에 로그아웃 요청
      await _repository.logout();
    } catch (e) {
      // 서버 요청 실패해도 클라이언트 토큰은 삭제
      print('서버 로그아웃 요청 실패: $e');
    } finally {
      // 2. 로컬 토큰 삭제
      await _tokenStorage.clearTokens();
    }
  }
  
  /// 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }
      
      // 서버에 토큰 갱신 요청
      final newTokens = await _repository.refreshToken(refreshToken);
      
      // 새 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
      );
      
      return true;
    } catch (e) {
      // 토큰 갱신 실패 시 기존 토큰 삭제
      await _tokenStorage.clearTokens();
      return false;
    }
  }
  
  /// 인증 상태 확인
  Future<bool> isAuthenticated() async {
    try {
      final isValid = await _tokenStorage.isTokenValid();
      return isValid;
    } catch (e) {
      return false;
    }
  }
}
