import 'package:get_it/get_it.dart';

// Domain layer imports
import '../../domains/auth/domain/entities/user.dart';
import '../../domains/auth/domain/entities/auth_token.dart';
import '../../domains/auth/domain/repositories/auth_repository.dart';
import '../../domains/auth/domain/usecases/authenticate_with_social.dart';
import '../../domains/social_login/domain/entities/social_account.dart';
import '../../domains/social_login/domain/repositories/social_auth_repository.dart';
import '../../domains/social_login/domain/usecases/kakao_login.dart';
import '../../domains/social_login/domain/usecases/google_login.dart';
import '../../domains/social_login/domain/usecases/apple_login.dart';

// Presentation layer imports
import '../../domains/auth/presentation/controllers/auth_controller.dart';

/// 의존성 주입 컨테이너
/// 
/// GetIt을 사용하여 앱 전체의 의존성을 관리합니다.
/// Clean Architecture의 의존성 역전 원칙을 구현하는 핵심 요소입니다.
final GetIt sl = GetIt.instance;

/// 의존성 초기화
/// 
/// 앱 시작 시 호출되어 모든 의존성을 등록합니다.
/// 등록 순서: Infrastructure → Data → Domain → Presentation
Future<void> initializeDependencies() async {
  // ===== External services (Infrastructure Layer) =====
  // TODO: 실제 구현 시 추가
  // sl.registerLazySingleton<Dio>(() => Dio());
  // sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  // ===== Data sources (Infrastructure) =====
  // TODO: 실제 구현 시 추가
  // sl.registerLazySingleton<KakaoDataSource>(() => KakaoDataSourceImpl());
  // sl.registerLazySingleton<GoogleDataSource>(() => GoogleDataSourceImpl());
  // sl.registerLazySingleton<AppleDataSource>(() => AppleDataSourceImpl());
  // sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  
  // ===== Repositories (Data Layer) =====
  // TODO: 실제 구현 시 추가
  // sl.registerLazySingleton<SocialAuthRepository>(
  //   () => SocialAuthRepositoryImpl(
  //     kakaoDataSource: sl(),
  //     googleDataSource: sl(),
  //     appleDataSource: sl(),
  //   ),
  // );
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //   ),
  // );

  // ===== Mock Repositories (임시 - 실제 구현 전까지) =====
  sl.registerLazySingleton<SocialAuthRepository>(() => MockSocialAuthRepository());
  sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
  
  // ===== Use cases (Domain Layer) =====
  sl.registerLazySingleton(() => KakaoLoginUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => AppleLoginUseCase(sl()));
  sl.registerLazySingleton(() => AuthenticateWithSocialUseCase(sl()));
  
  // ===== Controllers (Presentation Layer) =====
  sl.registerFactory(() => AuthController(
    kakaoLoginUseCase: sl(),
    googleLoginUseCase: sl(),
    appleLoginUseCase: sl(),
    authenticateUseCase: sl(),
  ));
}

// ===== Mock Implementations (임시) =====
// TODO: 실제 구현체로 교체

/// Mock 소셜 인증 Repository
class MockSocialAuthRepository implements SocialAuthRepository {
  @override
  Future<SocialAccount> loginWithKakao() async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock SocialAccount 반환
    return MockSocialAccount('kakao');
  }

  @override
  Future<SocialAccount> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return MockSocialAccount('google');
  }

  @override
  Future<SocialAccount> loginWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    return MockSocialAccount('apple');
  }

  @override
  Future<void> logout(String provider) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isAvailable(String provider) async {
    return true;
  }

  @override
  Future<SocialAccount> requestAdditionalScopes(String provider, List<String> scopes) async {
    await Future.delayed(const Duration(seconds: 1));
    return MockSocialAccount(provider);
  }
}

/// Mock 인증 Repository
class MockAuthRepository implements AuthRepository {
  @override
  Future<User> authenticateWithSocial(SocialAccount socialAccount) async {
    await Future.delayed(const Duration(seconds: 1));
    return MockUser();
  }

  @override
  Future<User> authenticateWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('이메일 로그인은 아직 구현되지 않았습니다.');
  }

  @override
  Future<User> registerWithEmail(String email, String password, {String? name}) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('회원가입은 아직 구현되지 않았습니다.');
  }

  @override
  Future<User?> getCurrentUser() async {
    return null;
  }

  @override
  Future<AuthToken?> getAuthToken() async {
    return null;
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    throw Exception('토큰 갱신은 아직 구현되지 않았습니다.');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isAuthenticated() async {
    return false;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('비밀번호 재설정은 아직 구현되지 않았습니다.');
  }
}

/// Mock SocialAccount
class MockSocialAccount implements SocialAccount {
  MockSocialAccount(this.provider);
  
  @override
  final String provider;
  
  @override
  String get providerUserId => '${provider}_user_123';
  
  @override
  String get accessToken => '${provider}_token_abc123';
  
  @override
  String? get email => '$provider@example.com';
  
  @override
  String? get name => '$provider User';
  
  @override
  String? get profileImageUrl => null;
  
  @override
  String? get refreshToken => null;
  
  @override
  DateTime? get expiresAt => DateTime.now().add(const Duration(hours: 1));
  
  @override
  Map<String, dynamic> get additionalData => {};
  
  @override
  bool get hasEmail => email != null && email!.isNotEmpty;
  
  @override
  bool get hasName => name != null && name!.isNotEmpty;
  
  @override
  bool get isTokenExpired => false;
  
  @override
  String get uniqueIdentifier => '${provider}_$providerUserId';
  
  @override
  SocialAccount copyWith({
    String? provider,
    String? providerUserId,
    String? accessToken,
    String? email,
    String? name,
    String? profileImageUrl,
    String? refreshToken,
    DateTime? expiresAt,
    Map<String, dynamic>? additionalData,
  }) {
    return MockSocialAccount(provider ?? this.provider);
  }
  
  @override
  List<Object?> get props => [
    provider,
    providerUserId,
    accessToken,
    email,
    name,
    profileImageUrl,
    refreshToken,
    expiresAt,
    additionalData,
  ];
  
  @override
  bool? get stringify => true;
}

/// Mock User
class MockUser implements User {
  @override
  String get id => 'user_123';
  
  @override
  String get email => 'user@example.com';
  
  @override
  String? get name => 'Test User';
  
  @override
  String? get profileImageUrl => null;
  
  @override
  String? get provider => null;
  
  @override
  DateTime get createdAt => DateTime.now();
  
  @override
  DateTime? get updatedAt => null;
  
  @override
  bool get isSocialUser => false;
  
  @override
  bool get isProfileComplete => true;
  
  @override
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? provider,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MockUser();
  }
  
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profileImageUrl,
    provider,
    createdAt,
    updatedAt,
  ];
  
  @override
  bool? get stringify => true;
}
