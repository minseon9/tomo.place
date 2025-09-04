import 'package:app/domains/auth/data/datasources/storage/auth_storage_data_source.dart';
import 'package:app/shared/infrastructure/storage/access_token_memory_store.dart';
import 'package:app/shared/infrastructure/storage/token_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../utils/fake_data_generator.dart';

class _MockAccessTokenMemoryStore extends Mock
    implements AccessTokenMemoryStore {}

class _MockTokenStorageService extends Mock implements TokenStorageService {}

void main() {
  group('AuthStorageDataSource', () {
    late _MockAccessTokenMemoryStore mockMemoryStore;
    late _MockTokenStorageService mockTokenStorage;
    late AuthStorageDataSource dataSource;

    setUp(() {
      mockMemoryStore = _MockAccessTokenMemoryStore();
      mockTokenStorage = _MockTokenStorageService();
      dataSource = AuthStorageDataSource(
        memoryStore: mockMemoryStore,
        tokenStorage: mockTokenStorage,
      );
    });

    group('getCurrentToken', () {
      test('모든 토큰 정보가 있을 때 AuthToken을 반환해야 한다', () async {
        // Given
        final now = DateTime.now();
        final accessToken = 'test_access_token';
        final refreshToken = 'test_refresh_token';
        final accessExpiry = now.add(const Duration(hours: 1));
        final refreshExpiry = now.add(const Duration(days: 30));

        when(() => mockMemoryStore.token).thenReturn(accessToken);
        when(() => mockMemoryStore.expiresAt).thenReturn(accessExpiry);
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenAnswer((_) async => refreshToken);
        when(
          () => mockTokenStorage.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => refreshExpiry);

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNotNull);
        expect(result!.accessToken, equals(accessToken));
        expect(result.refreshToken, equals(refreshToken));
        expect(result.accessTokenExpiresAt, equals(accessExpiry));
        expect(result.refreshTokenExpiresAt, equals(refreshExpiry));
        expect(result.tokenType, equals('Bearer'));
      });

      test('access token이 없을 때 null을 반환해야 한다', () async {
        // Given
        when(() => mockMemoryStore.token).thenReturn(null);
        when(() => mockMemoryStore.expiresAt).thenReturn(DateTime.now());
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenAnswer((_) async => 'refresh_token');
        when(
          () => mockTokenStorage.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => DateTime.now());

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('refresh token이 없을 때 null을 반환해야 한다', () async {
        // Given
        when(() => mockMemoryStore.token).thenReturn('access_token');
        when(() => mockMemoryStore.expiresAt).thenReturn(DateTime.now());
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenAnswer((_) async => null);
        when(
          () => mockTokenStorage.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => DateTime.now());

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('access token 만료 시간이 없을 때 null을 반환해야 한다', () async {
        // Given
        when(() => mockMemoryStore.token).thenReturn('access_token');
        when(() => mockMemoryStore.expiresAt).thenReturn(null);
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenAnswer((_) async => 'refresh_token');
        when(
          () => mockTokenStorage.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => DateTime.now());

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('refresh token 만료 시간이 없을 때 null을 반환해야 한다', () async {
        // Given
        when(() => mockMemoryStore.token).thenReturn('access_token');
        when(() => mockMemoryStore.expiresAt).thenReturn(DateTime.now());
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenAnswer((_) async => 'refresh_token');
        when(
          () => mockTokenStorage.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => null);

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('스토리지 오류 시 null을 반환해야 한다', () async {
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
        final authToken = FakeDataGenerator.createValidAuthToken();
        when(
          () => mockTokenStorage.saveRefreshToken(
            refreshToken: any(named: 'refreshToken'),
            refreshTokenExpiresAt: any(named: 'refreshTokenExpiresAt'),
          ),
        ).thenAnswer((_) async {});

        // When
        await dataSource.saveToken(authToken);

        // Then
        verify(
          () => mockTokenStorage.saveRefreshToken(
            refreshToken: authToken.refreshToken,
            refreshTokenExpiresAt: authToken.refreshTokenExpiresAt,
          ),
        ).called(1);
        verify(
          () => mockMemoryStore.set(
            authToken.accessToken,
            authToken.accessTokenExpiresAt,
          ),
        ).called(1);
      });

      test('토큰 저장 실패 시 예외를 전파해야 한다', () async {
        // Given
        final authToken = FakeDataGenerator.createValidAuthToken();
        final storageException = Exception('Storage save failed');
        when(
          () => mockTokenStorage.saveRefreshToken(
            refreshToken: any(named: 'refreshToken'),
            refreshTokenExpiresAt: any(named: 'refreshTokenExpiresAt'),
          ),
        ).thenThrow(storageException);

        // When & Then
        expect(
          () => dataSource.saveToken(authToken),
          throwsA(equals(storageException)),
        );
      });
    });

    group('clearToken', () {
      test('토큰을 올바르게 정리해야 한다', () async {
        // Given
        when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

        // When
        await dataSource.clearToken();

        // Then
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockMemoryStore.clear()).called(1);
      });

      test('토큰 정리 실패 시 예외를 전파해야 한다', () async {
        // Given
        final clearException = Exception('Clear failed');
        when(() => mockTokenStorage.clearTokens()).thenThrow(clearException);

        // When & Then
        expect(() => dataSource.clearToken(), throwsA(equals(clearException)));
      });
    });

    group('의존성 주입', () {
      test('필수 의존성이 올바르게 주입되어야 한다', () {
        // Given & When
        final dataSource = AuthStorageDataSource(
          memoryStore: mockMemoryStore,
          tokenStorage: mockTokenStorage,
        );

        // Then
        expect(dataSource, isA<AuthStorageDataSource>());
      });

      test('null 의존성은 허용되지 않아야 한다', () {
        // Given & When & Then
        expect(
          () => AuthStorageDataSource(
            memoryStore: null as dynamic,
            // ignore: cast_nullable_to_non_nullable, dead_code
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<TypeError>()),
        );

        expect(
          () => AuthStorageDataSource(
            memoryStore: mockMemoryStore,
            tokenStorage:
                null as dynamic, // ignore: cast_nullable_to_non_nullable
          ),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('에러 처리', () {
      test('메모리 스토어 오류를 적절히 처리해야 한다', () async {
        // Given
        when(
          () => mockMemoryStore.token,
        ).thenThrow(Exception('Memory store error'));

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });

      test('토큰 스토리지 오류를 적절히 처리해야 한다', () async {
        // Given
        when(() => mockMemoryStore.token).thenReturn('access_token');
        when(() => mockMemoryStore.expiresAt).thenReturn(DateTime.now());
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenThrow(Exception('Token storage error'));

        // When
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });
    });

    group('통합 시나리오', () {
      test('토큰 저장 후 조회가 올바르게 작동해야 한다', () async {
        // Given
        final authToken = FakeDataGenerator.createValidAuthToken();
        when(
          () => mockTokenStorage.saveRefreshToken(
            refreshToken: any(named: 'refreshToken'),
            refreshTokenExpiresAt: any(named: 'refreshTokenExpiresAt'),
          ),
        ).thenAnswer((_) async {});

        // 저장 시
        when(() => mockMemoryStore.token).thenReturn(authToken.accessToken);
        when(
          () => mockMemoryStore.expiresAt,
        ).thenReturn(authToken.accessTokenExpiresAt);
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenAnswer((_) async => authToken.refreshToken);
        when(
          () => mockTokenStorage.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => authToken.refreshTokenExpiresAt);

        // When
        await dataSource.saveToken(authToken);
        final retrievedToken = await dataSource.getCurrentToken();

        // Then
        expect(retrievedToken, isNotNull);
        expect(retrievedToken!.accessToken, equals(authToken.accessToken));
        expect(retrievedToken.refreshToken, equals(authToken.refreshToken));
      });

      test('토큰 정리 후 조회 시 null을 반환해야 한다', () async {
        // Given
        when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});
        when(() => mockMemoryStore.token).thenReturn(null);
        when(() => mockMemoryStore.expiresAt).thenReturn(null);
        when(
          () => mockTokenStorage.getRefreshToken(),
        ).thenAnswer((_) async => null);
        when(
          () => mockTokenStorage.getRefreshTokenExpiry(),
        ).thenAnswer((_) async => null);

        // When
        await dataSource.clearToken();
        final result = await dataSource.getCurrentToken();

        // Then
        expect(result, isNull);
      });
    });
  });
}
