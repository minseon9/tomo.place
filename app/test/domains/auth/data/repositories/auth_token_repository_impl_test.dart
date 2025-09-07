import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/data/repositories/auth_token_repository_impl.dart';
import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../utils/mock_factory/auth_mock_factory.dart';

void main() {
  group('AuthTokenRepositoryImpl', () {
    late MockAuthStorageDataSource mockStorageDataSource;
    late AuthTokenRepositoryImpl repository;

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
      mockStorageDataSource = AuthMockFactory.createAuthStorageDataSource();
      repository = AuthTokenRepositoryImpl(mockStorageDataSource);
    });

    group('getCurrentToken', () {
      test('저장된 토큰을 올바르게 반환해야 한다', () async {
        // Given
        final expectedToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockStorageDataSource.getCurrentToken())
            .thenAnswer((_) async => expectedToken);

        // When
        final result = await repository.getCurrentToken();

        // Then
        expect(result, equals(expectedToken));
        verify(() => mockStorageDataSource.getCurrentToken()).called(1);
      });

      test('저장된 토큰이 없을 때 null을 반환해야 한다', () async {
        // Given
        when(() => mockStorageDataSource.getCurrentToken())
            .thenAnswer((_) async => null);

        // When
        final result = await repository.getCurrentToken();

        // Then
        expect(result, isNull);
        verify(() => mockStorageDataSource.getCurrentToken()).called(1);
      });

      test('저장소 오류 시 예외를 그대로 전파해야 한다', () async {
        // Given
        final storageException = Exception('Storage error');

        when(() => mockStorageDataSource.getCurrentToken())
            .thenThrow(storageException);

        // When & Then
        expect(
          () => repository.getCurrentToken(),
          throwsA(isA<Exception>()),
        );

        verify(() => mockStorageDataSource.getCurrentToken()).called(1);
      });
    });

    group('saveToken', () {
      test('토큰을 올바르게 저장해야 한다', () async {
        // Given
        final token = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );

        when(() => mockStorageDataSource.saveToken(token))
            .thenAnswer((_) async {});

        // When
        await repository.saveToken(token);

        // Then
        verify(() => mockStorageDataSource.saveToken(token)).called(1);
      });

      test('저장소 오류 시 예외를 그대로 전파해야 한다', () async {
        // Given
        final token = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );
        final storageException = Exception('Storage error');

        when(() => mockStorageDataSource.saveToken(token))
            .thenThrow(storageException);

        // When & Then
        expect(
          () => repository.saveToken(token),
          throwsA(isA<Exception>()),
        );

        verify(() => mockStorageDataSource.saveToken(token)).called(1);
      });

      test('다른 토큰으로 덮어쓰기할 수 있어야 한다', () async {
        // Given
        final firstToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );
        final secondToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 2)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 14)),
          tokenType: 'Bearer',
        );

        when(() => mockStorageDataSource.saveToken(any()))
            .thenAnswer((_) async {});

        // When
        await repository.saveToken(firstToken);
        await repository.saveToken(secondToken);

        // Then
        verify(() => mockStorageDataSource.saveToken(firstToken)).called(1);
        verify(() => mockStorageDataSource.saveToken(secondToken)).called(1);
      });
    });

    group('clearToken', () {
      test('토큰을 올바르게 삭제해야 한다', () async {
        // Given
        when(() => mockStorageDataSource.clearToken())
            .thenAnswer((_) async {});

        // When
        await repository.clearToken();

        // Then
        verify(() => mockStorageDataSource.clearToken()).called(1);
      });

      test('저장소 오류 시 예외를 그대로 전파해야 한다', () async {
        // Given
        final storageException = Exception('Storage error');

        when(() => mockStorageDataSource.clearToken())
            .thenThrow(storageException);

        // When & Then
        expect(
          () => repository.clearToken(),
          throwsA(isA<Exception>()),
        );

        verify(() => mockStorageDataSource.clearToken()).called(1);
      });

      test('저장된 토큰이 없을 때도 정상 작동해야 한다', () async {
        // Given
        when(() => mockStorageDataSource.clearToken())
            .thenAnswer((_) async {});

        // When
        await repository.clearToken();

        // Then
        verify(() => mockStorageDataSource.clearToken()).called(1);
      });
    });
  });
}
