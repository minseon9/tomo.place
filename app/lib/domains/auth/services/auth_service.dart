import '../domain/repositories/auth_repository.dart';
import '../domain/entities/user.dart';
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
  
  /// 구글 로그인
  Future<User> loginWithGoogle() async {
    try {
      // 1. OAuth 플로우로 인증 코드 획득
      final authCode = await _oauthService.authenticate('GOOGLE');
      
      // 2. 서버에 인증 요청
      final user = await _repository.authenticate('GOOGLE', authCode);
      
      // 3. 토큰 저장
      if (user.accessToken != null && user.refreshToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: user.accessToken!,
          refreshToken: user.refreshToken!,
        );
      }
      
      return user;
    } catch (e) {
      throw AuthException('구글 로그인에 실패했습니다: ${e.toString()}');
    }
  }
  
  /// 구글 회원가입
  Future<User> signupWithGoogle() async {
    try {
      // 1. OAuth 플로우로 인증 코드 획득
      final authCode = await _oauthService.authenticate('GOOGLE');
      
      // 2. 서버에 회원가입 요청
      final user = await _repository.register('GOOGLE', authCode);
      
      // 3. 토큰 저장
      if (user.accessToken != null && user.refreshToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: user.accessToken!,
          refreshToken: user.refreshToken!,
        );
      }
      
      return user;
    } catch (e) {
      throw AuthException('구글 회원가입에 실패했습니다: ${e.toString()}');
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
  
  /// 현재 사용자 조회
  Future<User?> getCurrentUser() async {
    try {
      // 1. 토큰 유효성 확인
      final isValid = await _tokenStorage.isTokenValid();
      if (!isValid) {
        // 토큰이 유효하지 않으면 삭제
        await _tokenStorage.clearTokens();
        return null;
      }
      
      // 2. 서버에서 사용자 정보 조회
      return await _repository.getCurrentUser();
    } catch (e) {
      // 조회 실패 시 토큰 삭제
      await _tokenStorage.clearTokens();
      return null;
    }
  }
  
  /// 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }
      
      // TODO: 서버에 토큰 갱신 요청
      // final newTokens = await _repository.refreshToken(refreshToken);
      // await _tokenStorage.saveTokens(
      //   accessToken: newTokens.accessToken,
      //   refreshToken: newTokens.refreshToken,
      // );
      
      return true;
    } catch (e) {
      // 갱신 실패 시 토큰 삭제
      await _tokenStorage.clearTokens();
      return false;
    }
  }
  
  /// 인증 상태 확인
  Future<bool> isAuthenticated() async {
    try {
      final isValid = await _tokenStorage.isTokenValid();
      if (!isValid) {
        return false;
      }
      
      final user = await _repository.getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }
}
