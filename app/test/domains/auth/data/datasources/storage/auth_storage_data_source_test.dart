import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/data/datasources/storage/auth_storage_data_source.dart';
import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../utils/mock_factory/shared_mock_factory.dart';

void main() {
  group('AuthStorageDataSource', () {
    late MockAccessTokenMemoryStoreInterface mockMemoryStore;
    late MockTokenStorageInterface mockTokenStorage;
    late AuthStorageDataSource dataSource;

    setUp(() {
      mockMemoryStore = SharedMockFactory.createAccessTokenMemoryStore();
      mockTokenStorage = SharedMockFactory.createTokenStorage();
      dataSource = AuthStorageDataSource(
        memoryStore: mockMemoryStore,
        tokenStorage: mockTokenStorage,
      );
    });

    group('getCurrentToken', () {
      test('저장된 토큰을 올바르게 반환해야 한다', () async {
        // Given
        final accessToken = faker.guid.guid();
        final accessTokenExpiresAt = clock.now().add(const Duration(hours: 1));
        final refreshToken = faker.guid.guid();
        final refreshTokenExpiresAt = clock.now().add(const Duration(days: 7));

        when(() => mockMemoryStore.token).thenReturn(accessToken);
        when(() => mockMemoryStore.expiresAt).thenReturn(accessTokenExpiresAt);
        when(() => mockTokenStorage.getRefreshToken()).thenAnswer((_) async => refreshToken);
        when(() => mockTokenStorage.getRefreshTokenExpiry()).thenAnswer((_) async => refreshTokenExpiresAt);

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNotNull);
        expect(result!.accessToken, equals(accessToken));
        expect(result.accessTokenExpiresAt, equals(accessTokenExpiresAt));
        expect(result.refreshToken, equals(refreshToken));
        expect(result.refreshTokenExpiresAt, equals(refreshTokenExpiresAt));
        expect(result.tokenType, equals('Bearer'));
      });

      test('저장된 토큰이 없을 때 null을 반환해야 한다', () async {
        // Given
        when(() => mockMemoryStore.token).thenReturn(null);
        when(() => mockMemoryStore.expiresAt).thenReturn(null);
        when(() => mockTokenStorage.getRefreshToken()).thenAnswer((_) async => null);
        when(() => mockTokenStorage.getRefreshTokenExpiry()).thenAnswer((_) async => null);

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('accessToken이 null일 때 null을 반환해야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final refreshTokenExpiresAt = clock.now().add(const Duration(days: 7));

        when(() => mockMemoryStore.token).thenReturn(null);
        when(() => mockMemoryStore.expiresAt).thenReturn(clock.now().add(const Duration(hours: 1)));
        when(() => mockTokenStorage.getRefreshToken()).thenAnswer((_) async => refreshToken);
        when(() => mockTokenStorage.getRefreshTokenExpiry()).thenAnswer((_) async => refreshTokenExpiresAt);

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('refreshToken이 null일 때 null을 반환해야 한다', () async {
        // Given
        final accessToken = faker.guid.guid();
        final accessTokenExpiresAt = clock.now().add(const Duration(hours: 1));

        when(() => mockMemoryStore.token).thenReturn(accessToken);
        when(() => mockMemoryStore.expiresAt).thenReturn(accessTokenExpiresAt);
        when(() => mockTokenStorage.getRefreshToken()).thenAnswer((_) async => null);
        when(() => mockTokenStorage.getRefreshTokenExpiry()).thenAnswer((_) async => clock.now().add(const Duration(days: 7)));

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('accessTokenExpiresAt이 null일 때 null을 반환해야 한다', () async {
        // Given
        final accessToken = faker.guid.guid();
        final refreshToken = faker.guid.guid();
        final refreshTokenExpiresAt = clock.now().add(const Duration(days: 7));

        when(() => mockMemoryStore.token).thenReturn(accessToken);
        when(() => mockMemoryStore.expiresAt).thenReturn(null);
        when(() => mockTokenStorage.getRefreshToken()).thenAnswer((_) async => refreshToken);
        when(() => mockTokenStorage.getRefreshTokenExpiry()).thenAnswer((_) async => refreshTokenExpiresAt);

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('refreshTokenExpiresAt이 null일 때 null을 반환해야 한다', () async {
        // Given
        final accessToken = faker.guid.guid();
        final accessTokenExpiresAt = clock.now().add(const Duration(hours: 1));
        final refreshToken = faker.guid.guid();

        when(() => mockMemoryStore.token).thenReturn(accessToken);
        when(() => mockMemoryStore.expiresAt).thenReturn(accessTokenExpiresAt);
        when(() => mockTokenStorage.getRefreshToken()).thenAnswer((_) async => refreshToken);
        when(() => mockTokenStorage.getRefreshTokenExpiry()).thenAnswer((_) async => null);

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('저장소 오류 시 null을 반환해야 한다', () async {
        // Given
        when(() => mockMemoryStore.token).thenThrow(Exception('Storage error'));

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
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

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: token.refreshToken,
          refreshTokenExpiresAt: token.refreshTokenExpiresAt,
        )).thenAnswer((_) async {});

        // When
        await dataSource.saveToken(token);

        // Then
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: token.refreshToken,
          refreshTokenExpiresAt: token.refreshTokenExpiresAt,
        )).called(1);
        verify(() => mockMemoryStore.set(token.accessToken, token.accessTokenExpiresAt)).called(1);
      });

      test('기존 토큰을 덮어쓰기해야 한다', () async {
        // Given
        final oldToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );
        final newToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 2)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 14)),
          tokenType: 'Bearer',
        );

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: any(named: 'refreshToken'),
          refreshTokenExpiresAt: any(named: 'refreshTokenExpiresAt'),
        )).thenAnswer((_) async {});

        // When
        await dataSource.saveToken(oldToken);
        await dataSource.saveToken(newToken);

        // Then
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: oldToken.refreshToken,
          refreshTokenExpiresAt: oldToken.refreshTokenExpiresAt,
        )).called(1);
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: newToken.refreshToken,
          refreshTokenExpiresAt: newToken.refreshTokenExpiresAt,
        )).called(1);
        verify(() => mockMemoryStore.set(oldToken.accessToken, oldToken.accessTokenExpiresAt)).called(1);
        verify(() => mockMemoryStore.set(newToken.accessToken, newToken.accessTokenExpiresAt)).called(1);
      });

      test('저장소 오류 시 예외를 던져야 한다', () async {
        // Given
        final token = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)),
          tokenType: 'Bearer',
        );
        final storageException = Exception('Storage error');

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: token.refreshToken,
          refreshTokenExpiresAt: token.refreshTokenExpiresAt,
        )).thenThrow(storageException);

        // When & Then
        expect(
          () => dataSource.saveToken(token),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('clearToken', () {
      test('토큰을 올바르게 삭제해야 한다', () async {
        // Given
        when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

        // When
        await dataSource.clearToken();

        // Then
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockMemoryStore.clear()).called(1);
      });

      test('저장된 토큰이 없을 때도 정상 작동해야 한다', () async {
        // Given
        when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

        // When
        await dataSource.clearToken();

        // Then
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockMemoryStore.clear()).called(1);
      });

      test('저장소 오류 시 예외를 던져야 한다', () async {
        // Given
        final storageException = Exception('Storage error');

        when(() => mockTokenStorage.clearTokens()).thenThrow(storageException);

        // When & Then
        expect(
          () => dataSource.clearToken(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
