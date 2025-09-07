import 'package:app/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:faker/faker.dart';
import 'package:clock/clock.dart';

import '../../../../utils/mock_factory/auth_mock_factory.dart';

void main() {
  group('RefreshTokenUseCase', () {
    late MockAuthRepository mockAuthRepository;
    late MockAuthTokenRepository mockAuthTokenRepository;
    late RefreshTokenUseCase useCase;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(AuthToken(
        accessToken: 'fallback',
        accessTokenExpiresAt: DateTime.now(),
        refreshToken: 'fallback',
        refreshTokenExpiresAt: DateTime.now(),
      ));
    });

    setUp(() {
      mockAuthRepository = AuthMockFactory.createAuthRepository();
      mockAuthTokenRepository = AuthMockFactory.createAuthTokenRepository();
      useCase = RefreshTokenUseCase(mockAuthRepository, mockAuthTokenRepository);
    });

    group('성공 케이스', () {
      test('현재 토큰이 없을 때 unauthenticated를 반환해야 한다', () async {
        // Given
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
        verifyNever(() => mockAuthRepository.refreshToken(any()));
      });

      test('리프레시 토큰이 유효할 때 현재 토큰을 반환해야 한다', () async {
        // Given
        final validToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().subtract(const Duration(minutes: 10)), // 액세스 만료
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)), // 리프레시 유효
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => validToken);

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.authenticated));
        expect(result.token, equals(validToken));
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
        verifyNever(() => mockAuthRepository.refreshToken(any()));
      });

      test('리프레시 토큰이 만료되었을 때 새 토큰을 받아와야 한다', () async {
        // Given
        final expiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().subtract(const Duration(minutes: 10)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().subtract(const Duration(hours: 1)), // 리프레시 만료
          tokenType: 'Bearer',
        );

        final newToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => expiredToken);
        when(() => mockAuthRepository.refreshToken(expiredToken.refreshToken))
            .thenAnswer((_) async => newToken);
        when(() => mockAuthTokenRepository.saveToken(newToken))
            .thenAnswer((_) async {});

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.authenticated));
        expect(result.token, equals(newToken));
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
        verify(() => mockAuthRepository.refreshToken(expiredToken.refreshToken)).called(1);
        verify(() => mockAuthTokenRepository.saveToken(newToken)).called(1);
      });

      test('새로운 토큰이 올바르게 저장되어야 한다', () async {
        // Given
        final expiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().subtract(const Duration(minutes: 10)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().subtract(const Duration(hours: 1)),
          tokenType: 'Bearer',
        );

        final newToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => expiredToken);
        when(() => mockAuthRepository.refreshToken(expiredToken.refreshToken))
            .thenAnswer((_) async => newToken);
        when(() => mockAuthTokenRepository.saveToken(newToken))
            .thenAnswer((_) async {});

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.authenticated));
        verify(() => mockAuthTokenRepository.saveToken(newToken)).called(1);
      });
    });

    group('실패 케이스', () {
      test('토큰 갱신 실패 시 토큰을 삭제하고 unauthenticated를 반환해야 한다', () async {
        // Given
        final expiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().subtract(const Duration(minutes: 10)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().subtract(const Duration(hours: 1)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => expiredToken);
        when(() => mockAuthRepository.refreshToken(expiredToken.refreshToken))
            .thenThrow(Exception('Refresh failed'));
        when(() => mockAuthTokenRepository.clearToken())
            .thenAnswer((_) async {});

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        expect(result.message, contains('Token refresh failed'));
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
        verify(() => mockAuthRepository.refreshToken(expiredToken.refreshToken)).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });

      test('네트워크 오류 시 토큰을 삭제하고 unauthenticated를 반환해야 한다', () async {
        // Given
        final expiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().subtract(const Duration(minutes: 10)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().subtract(const Duration(hours: 1)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => expiredToken);
        when(() => mockAuthRepository.refreshToken(expiredToken.refreshToken))
            .thenThrow(Exception('Network error'));
        when(() => mockAuthTokenRepository.clearToken())
            .thenAnswer((_) async {});

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });

      test('저장 실패 시에도 토큰을 삭제하고 unauthenticated를 반환해야 한다', () async {
        // Given
        final expiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().subtract(const Duration(minutes: 10)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().subtract(const Duration(hours: 1)),
          tokenType: 'Bearer',
        );

        final newToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => expiredToken);
        when(() => mockAuthRepository.refreshToken(expiredToken.refreshToken))
            .thenAnswer((_) async => newToken);
        when(() => mockAuthTokenRepository.saveToken(newToken))
            .thenThrow(Exception('Storage error'));
        when(() => mockAuthTokenRepository.clearToken())
            .thenAnswer((_) async {});

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });

    group('경계값 테스트', () {
      test('null 토큰 처리', () async {
        // Given
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        expect(result.token, isNull);
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });

      test('토큰 저장소 오류 시 null 반환 처리', () async {
        // Given
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenThrow(Exception('Storage error'));
        when(() => mockAuthTokenRepository.clearToken())
            .thenAnswer((_) async {});

        // When
        final result = await useCase.execute();

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });
  });
}
