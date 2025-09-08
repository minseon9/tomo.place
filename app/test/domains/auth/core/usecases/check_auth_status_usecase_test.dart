import 'package:tomo_place/domains/auth/core/usecases/check_auth_status_usecase.dart';
import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:faker/faker.dart';
import 'package:clock/clock.dart';

import '../../../../utils/mock_factory/auth_mock_factory.dart';

void main() {
  group('CheckAuthStatusUseCase', () {
    late MockAuthTokenRepository mockAuthTokenRepository;
    late CheckAuthStatusUseCase useCase;

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
      mockAuthTokenRepository = AuthMockFactory.createAuthTokenRepository();
      useCase = CheckAuthStatusUseCase(authTokenRepository: mockAuthTokenRepository);
    });

    group('성공 케이스', () {
      test('유효한 토큰이 있을 때 인증 상태를 올바르게 반환해야 한다', () async {
        // Given
        final validToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => validToken);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isTrue);
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });

      test('토큰이 없을 때 미인증 상태를 올바르게 반환해야 한다', () async {
        // Given
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isFalse);
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });

      test('만료된 토큰일 때 미인증 상태를 올바르게 반환해야 한다', () async {
        // Given
        final expiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().subtract(const Duration(hours: 1)), // 만료됨
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => expiredToken);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isFalse);
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });

      test('액세스 토큰이 곧 만료될 때는 유효하지 않은 상태로 반환해야 한다', () async {
        // Given
        final tokenAboutToExpire = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(minutes: 3)), // 3분 후 만료
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => tokenAboutToExpire);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isFalse); // isAccessTokenAboutToExpire가 true이므로 isAccessTokenValid는 false
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });
    });

    group('실패 케이스', () {
      test('저장소 오류 시 false를 반환해야 한다', () async {
        // Given
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenThrow(Exception('Storage error'));

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isFalse);
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });

      test('네트워크 오류 시 false를 반환해야 한다', () async {
        // Given
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenThrow(Exception('Network error'));

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isFalse);
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });
    });

    group('경계값 테스트', () {
      test('정확히 만료 시점인 토큰은 false를 반환해야 한다', () async {
        // Given
        final exactlyExpiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now(), // 정확히 현재 시간에 만료
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => exactlyExpiredToken);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isFalse);
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });

      test('리프레시 토큰이 만료되어도 액세스 토큰이 유효하면 true를 반환해야 한다', () async {
        // Given
        final tokenWithExpiredRefresh = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().subtract(const Duration(hours: 1)), // 리프레시 토큰 만료
          tokenType: 'Bearer',
        );

        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => tokenWithExpiredRefresh);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isTrue); // 액세스 토큰이 유효하므로 true
        verify(() => mockAuthTokenRepository.getCurrentToken()).called(1);
      });
    });
  });
}
