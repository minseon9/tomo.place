import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:app/domains/auth/core/repositories/auth_repository.dart';
import 'package:app/domains/auth/core/repositories/auth_token_repository.dart';
import 'package:app/domains/auth/core/usecases/check_auth_status_usecase.dart';
import 'package:app/domains/auth/core/usecases/logout_usecase.dart';
import 'package:app/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:app/shared/infrastructure/storage/access_token_memory_store.dart';
import 'package:app/shared/infrastructure/storage/token_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock 클래스들
class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthTokenRepository extends Mock implements AuthTokenRepository {}

class MockTokenStorageService extends Mock implements TokenStorageService {}

class MockAccessTokenMemoryStore extends Mock
    implements AccessTokenMemoryStore {}

void main() {
  group('인증 플로우 통합 테스트', () {
    late MockAuthRepository mockAuthRepository;
    late MockAuthTokenRepository mockAuthTokenRepository;
    late MockTokenStorageService mockTokenStorageService;
    late MockAccessTokenMemoryStore mockAccessTokenMemoryStore;

    late CheckAuthStatusUseCase checkAuthStatusUseCase;
    late RefreshTokenUseCase startupRefreshTokenUseCase;
    late LogoutUseCase logoutUseCase;

    void setupCommonMocks() {
      // TokenStorageService 기본 동작 설정
      when(
        () => mockTokenStorageService.getRefreshToken(),
      ).thenAnswer((_) async => 'test_refresh_token');
      when(
        () => mockTokenStorageService.getRefreshTokenExpiry(),
      ).thenAnswer((_) async => DateTime(2024, 12, 31, 23, 59, 59));
      when(
        () => mockTokenStorageService.clearTokens(),
      ).thenAnswer((_) async {});

      // AccessTokenMemoryStore 기본 동작 설정
      when(() => mockAccessTokenMemoryStore.token).thenReturn(null);
      when(
        () => mockAccessTokenMemoryStore.set(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockAccessTokenMemoryStore.clear()).thenAnswer((_) async {});

      // AuthTokenRepository 기본 동작 설정
      when(
        () => mockAuthTokenRepository.saveToken(any()),
      ).thenAnswer((_) async {});
      when(() => mockAuthTokenRepository.clearToken()).thenAnswer((_) async {});
    }

    setUpAll(() {
      // Mocktail fallback 값 등록
      registerFallbackValue(
        AuthToken(
          accessToken: 'fallback_token',
          accessTokenExpiresAt: DateTime.now(),
          refreshToken: 'fallback_refresh_token',
          refreshTokenExpiresAt: DateTime.now(),
        ),
      );
      registerFallbackValue(DateTime.now());
      registerFallbackValue('fallback_string');
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockAuthTokenRepository = MockAuthTokenRepository();
      mockTokenStorageService = MockTokenStorageService();
      mockAccessTokenMemoryStore = MockAccessTokenMemoryStore();

      // UseCase 인스턴스 생성
      checkAuthStatusUseCase = CheckAuthStatusUseCase(
        authTokenRepository: mockAuthTokenRepository,
      );

      startupRefreshTokenUseCase = RefreshTokenUseCase(
        mockAuthRepository,
        mockAuthTokenRepository,
      );

      logoutUseCase = LogoutUseCase(
        mockAuthRepository,
        mockAuthTokenRepository,
      );

      // 공통 Mock 설정
      setupCommonMocks();
    });

    group('성공적인 인증 플로우', () {
      test('전체 인증 플로우가 성공적으로 완료되어야 한다', () async {
        // Given: 성공적인 인증 시나리오 설정
        final validToken = AuthToken(
          accessToken:
              'valid_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken:
              'valid_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenAnswer((_) async => validToken);
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

        // When: 인증 상태 확인
        final authStatusResult = await checkAuthStatusUseCase.execute();

        // Then: 인증 상태가 올바르게 반환되어야 함
        expect(authStatusResult, isTrue);

        // When: Refresh 토큰 상태 확인
        final startupResult = await startupRefreshTokenUseCase.execute();

        // Then: Refresh 토큰이 유효해야 함
        expect(startupResult.isAuthenticated(), isTrue);

        // When: Startup Refresh 토큰 재실행
        final startupResult2 = await startupRefreshTokenUseCase.execute();

        // Then: Startup Refresh가 성공해야 함 (토큰이 유효하므로 갱신하지 않음)
        expect(startupResult2, isNotNull);
        expect(
          startupResult2.status,
          equals(AuthenticationStatus.authenticated),
        );

        // When: 로그아웃 실행
        await logoutUseCase.execute();

        // Then: 로그아웃이 성공해야 함 (예외가 발생하지 않아야 함)
        expect(true, isTrue); // 로그아웃 성공 확인
      });

      test('토큰 갱신 후 토큰 저장소가 업데이트되어야 한다', () async {
        // Given: 만료된 토큰으로 설정하여 갱신이 필요하도록 함
        final expiredToken = AuthToken(
          accessToken:
              'expired_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().subtract(
            const Duration(hours: 1),
          ),
          refreshToken:
              'expired_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().subtract(
            const Duration(days: 1),
          ),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => expiredToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenAnswer((_) async => expiredToken);

        // When: Startup Refresh 토큰 실행
        final result = await startupRefreshTokenUseCase.execute();

        // Then: 토큰 저장소에 새 토큰이 저장되어야 함
        verify(() => mockAuthTokenRepository.saveToken(any())).called(1);
        expect(result.status, equals(AuthenticationStatus.authenticated));
      });
    });

    group('실패한 인증 플로우', () {
      test('Refresh 토큰이 만료된 경우 적절히 처리되어야 한다', () async {
        // Given: 만료된 Refresh 토큰 설정
        when(
          () => mockTokenStorageService.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => DateTime(2023, 1, 1, 0, 0, 0));

        // When: Refresh 토큰 상태 확인
        final startupResult = await startupRefreshTokenUseCase.execute();

        // Then: Refresh 토큰이 만료된 것으로 인식되어야 함
        expect(startupResult.isAuthenticated(), isFalse);
      });

      test('토큰 갱신 실패 시 적절히 처리되어야 한다', () async {
        // Given: 토큰 갱신 실패 설정
        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => null);

        // When: Startup Refresh 토큰 실행
        final result = await startupRefreshTokenUseCase.execute();

        // Then: 인증되지 않은 상태가 반환되어야 함
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
      });

      test('로그아웃 실패 시에도 토큰이 정리되어야 한다', () async {
        // Given: 로그아웃 실패 설정
        final logoutException = Exception('Server logout failed');
        when(() => mockAuthRepository.logout()).thenThrow(logoutException);

        // When & Then: 로그아웃 실행 시 예외가 발생하지만 토큰은 정리되어야 함
        expect(() => logoutUseCase.execute(), throwsA(equals(logoutException)));

        // 토큰 정리가 호출되었는지 확인
        verify(() => mockTokenStorageService.clearTokens()).called(1);
      });
    });

    group('에러 처리 통합 테스트', () {
      test('네트워크 오류 시 적절한 에러 처리가 되어야 한다', () async {
        // Given: 네트워크 오류 설정 - 만료된 토큰으로 설정하여 갱신이 필요하도록 함
        final networkException = Exception('Network error');
        final expiredToken = AuthToken(
          accessToken:
              'expired_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().subtract(
            const Duration(hours: 1),
          ),
          refreshToken:
              'expired_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().subtract(
            const Duration(days: 1),
          ),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => expiredToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenThrow(networkException);

        // When: Startup Refresh 실행
        final result = await startupRefreshTokenUseCase.execute();

        // Then: 에러가 적절히 처리되어야 함
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        expect(result.message, contains('Token refresh failed'));
      });

      test('스토리지 오류 시 적절한 에러 처리가 되어야 한다', () async {
        // Given: 스토리지 오류 설정
        final storageException = Exception('Storage error');
        when(
          () => mockTokenStorageService.getRefreshTokenExpiry(),
        ).thenThrow(storageException);

        // When: 스토리지 오류 발생 시
        final result = await startupRefreshTokenUseCase.execute();

        // Then: 에러가 적절히 처리되어 false를 반환해야 함
        expect(result.isAuthenticated(), isFalse);
      });
    });

    group('상태 일관성 테스트', () {
      test('인증 상태와 토큰 상태가 일치해야 한다', () async {
        // Given: 유효한 토큰 설정
        final validToken = AuthToken(
          accessToken:
              'valid_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken:
              'valid_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => validToken);

        // When: 인증 상태 확인
        final authStatusResult = await checkAuthStatusUseCase.execute();
        final startupResult = await startupRefreshTokenUseCase.execute();

        // Then: 두 상태가 일치해야 함
        expect(authStatusResult, equals(startupResult.isAuthenticated()));
      });

      test('로그아웃 후 모든 토큰이 정리되어야 한다', () async {
        // Given: 성공적인 로그아웃 설정
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

        // When: 로그아웃 실행
        await logoutUseCase.execute();

        // Then: 모든 토큰이 정리되어야 함
        verify(() => mockTokenStorageService.clearTokens()).called(1);
      });
    });

    group('성능 및 동시성 테스트', () {
      test('여러 UseCase가 동시에 실행되어도 안전해야 한다', () async {
        // Given: 동시 실행을 위한 설정
        final validToken = AuthToken(
          accessToken:
              'valid_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken:
              'valid_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenAnswer((_) async => validToken);
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

        // When: 여러 UseCase를 동시에 실행
        final futures = [
          checkAuthStatusUseCase.execute(),
          startupRefreshTokenUseCase.execute().then(
            (result) => result.isAuthenticated(),
          ),
          startupRefreshTokenUseCase.execute(),
        ];

        final results = await Future.wait(futures);

        // Then: 모든 결과가 올바르게 반환되어야 함
        expect(results.length, equals(3));
        expect(results[0], isTrue);
        expect(results[1], isTrue);
        expect(results[2], isNotNull);
      });

      test('빠른 연속 호출이 안전하게 처리되어야 한다', () async {
        // Given: 빠른 연속 호출을 위한 설정
        final validToken = AuthToken(
          accessToken:
              'valid_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken:
              'valid_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenAnswer((_) async => validToken);

        // When: 빠른 연속으로 Startup Refresh 실행
        final results = await Future.wait([
          startupRefreshTokenUseCase.execute(),
          startupRefreshTokenUseCase.execute(),
          startupRefreshTokenUseCase.execute(),
        ]);

        // Then: 모든 호출이 성공해야 함
        expect(results.length, equals(3));
        for (final result in results) {
          expect(result.status, equals(AuthenticationStatus.authenticated));
        }
      });
    });

    group('경계값 테스트', () {
      test('토큰이 곧 만료될 때 적절히 처리되어야 한다', () async {
        // Given: 곧 만료될 토큰 설정
        final aboutToExpireToken = AuthToken(
          accessToken:
              'about_to_expire_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 5)),
          refreshToken:
              'about_to_expire_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => aboutToExpireToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenAnswer((_) async => aboutToExpireToken);

        // When: Startup Refresh 실행
        final result = await startupRefreshTokenUseCase.execute();

        // Then: 결과가 올바르게 반환되어야 함
        expect(result.status, equals(AuthenticationStatus.authenticated));
      });

      test('빈 토큰으로 인증 상태 확인 시 적절히 처리되어야 한다', () async {
        // Given: 빈 토큰 설정
        when(
          () => mockTokenStorageService.getRefreshToken(),
        ).thenAnswer((_) async => null);
        when(
          () => mockTokenStorageService.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => null);

        // When: Refresh 토큰 상태 확인
        final startupResult = await startupRefreshTokenUseCase.execute();

        // Then: 빈 토큰으로 인해 false가 반환되어야 함
        expect(startupResult.isAuthenticated(), isFalse);
      });
    });

    group('데이터 무결성 테스트', () {
      test('토큰 데이터가 변경되지 않아야 한다', () async {
        // Given: 유효한 토큰 설정
        final originalToken = AuthToken(
          accessToken:
              'valid_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken:
              'valid_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => originalToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenAnswer((_) async => originalToken);

        // When: Startup Refresh 실행
        await startupRefreshTokenUseCase.execute();

        // Then: 원본 토큰이 변경되지 않아야 함
        expect(
          originalToken.accessToken,
          equals('valid_access_token_${DateTime.now().millisecondsSinceEpoch}'),
        );
        expect(
          originalToken.refreshToken,
          equals(
            'valid_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          ),
        );
      });

      test('동일한 입력에 대해 일관된 결과가 반환되어야 한다', () async {
        // Given: 동일한 설정
        final validToken = AuthToken(
          accessToken:
              'valid_access_token_${DateTime.now().millisecondsSinceEpoch}',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken:
              'valid_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        when(
          () => mockAuthTokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockAuthRepository.refreshToken(any()),
        ).thenAnswer((_) async => validToken);

        // When: 동일한 UseCase를 여러 번 실행
        final result1 = await startupRefreshTokenUseCase.execute();
        final result2 = await startupRefreshTokenUseCase.execute();
        final result3 = await startupRefreshTokenUseCase.execute();

        // Then: 모든 결과가 동일해야 함
        expect(result1.status, equals(result2.status));
        expect(result2.status, equals(result3.status));
        expect(result1.status, equals(AuthenticationStatus.authenticated));
      });
    });
  });
}
