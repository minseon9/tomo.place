import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/auth/core/repositories/auth_repository.dart';
import 'package:tomo_place/domains/auth/core/repositories/auth_token_repository.dart';
import 'package:tomo_place/domains/auth/core/usecases/check_auth_status_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/logout_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/signup_with_social_usecase.dart';
import 'package:tomo_place/domains/auth/data/datasources/api/auth_api_data_source.dart';
import 'package:tomo_place/domains/auth/data/datasources/storage/auth_storage_data_source.dart';

/// Auth 도메인 전용 Mock 클래스들
class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthTokenRepository extends Mock implements AuthTokenRepository {}

class MockAuthApiDataSource extends Mock implements AuthApiDataSource {}

class MockAuthStorageDataSource extends Mock implements AuthStorageDataSource {}

class MockSignupWithSocialUseCase extends Mock implements SignupWithSocialUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}

/// Auth 도메인 Mock 객체 생성을 위한 팩토리 클래스
class AuthMockFactory {
  AuthMockFactory._();

  // Repository Mocks
  static MockAuthRepository createAuthRepository() => MockAuthRepository();
  static MockAuthTokenRepository createAuthTokenRepository() => MockAuthTokenRepository();

  // DataSource Mocks
  static MockAuthApiDataSource createAuthApiDataSource() => MockAuthApiDataSource();
  static MockAuthStorageDataSource createAuthStorageDataSource() => MockAuthStorageDataSource();

  // UseCase Mocks
  static MockSignupWithSocialUseCase createSignupUseCase() => MockSignupWithSocialUseCase();
  static MockSignupWithSocialUseCase createSignupWithSocialUseCase() => MockSignupWithSocialUseCase();
  static MockLogoutUseCase createLogoutUseCase() => MockLogoutUseCase();
  static MockRefreshTokenUseCase createRefreshTokenUseCase() => MockRefreshTokenUseCase();
  static MockCheckAuthStatusUseCase createCheckAuthStatusUseCase() => MockCheckAuthStatusUseCase();
}

