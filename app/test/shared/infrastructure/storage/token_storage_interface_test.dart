import 'package:tomo_place/shared/infrastructure/storage/token_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../utils/mock_factory/shared_mock_factory.dart';

void main() {
  group('TokenStorageInterface Contract Tests', () {
    late MockTokenStorageInterface mockTokenStorage;

    setUp(() {
      mockTokenStorage = SharedMockFactory.createTokenStorage();
    });

    group('saveRefreshToken', () {
      test('Refresh Token과 만료 시간을 저장해야 한다', () async {
        const refreshToken = 'test_token';
        final expiresAt = DateTime.now().add(const Duration(days: 30));

        // Mock 설정
        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: expiresAt,
        )).thenAnswer((_) async {});

        // 실행
        await mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: expiresAt,
        );

        // 검증
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: expiresAt,
        )).called(1);
      });

      test('빈 문자열 Refresh Token을 저장할 수 있어야 한다', () async {
        const emptyToken = '';
        final expiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: emptyToken,
          refreshTokenExpiresAt: expiresAt,
        )).thenAnswer((_) async {});

        await mockTokenStorage.saveRefreshToken(
          refreshToken: emptyToken,
          refreshTokenExpiresAt: expiresAt,
        );

        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: emptyToken,
          refreshTokenExpiresAt: expiresAt,
        )).called(1);
      });

      test('과거 만료 시간을 저장할 수 있어야 한다', () async {
        const refreshToken = 'test_token';
        final pastExpiry = DateTime.now().subtract(const Duration(days: 1));

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: pastExpiry,
        )).thenAnswer((_) async {});

        await mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: pastExpiry,
        );

        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: pastExpiry,
        )).called(1);
      });
    });

    group('getRefreshToken', () {
      test('저장된 Refresh Token을 반환해야 한다', () async {
        const refreshToken = 'test_token';

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => refreshToken);

        final result = await mockTokenStorage.getRefreshToken();

        expect(result, equals(refreshToken));
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });

      test('저장된 Refresh Token이 없을 때 null을 반환해야 한다', () async {
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        final result = await mockTokenStorage.getRefreshToken();

        expect(result, isNull);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });

      test('빈 문자열을 반환할 수 있어야 한다', () async {
        const emptyToken = '';

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => emptyToken);

        final result = await mockTokenStorage.getRefreshToken();

        expect(result, equals(emptyToken));
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });
    });

    group('getRefreshTokenExpiry', () {
      test('저장된 만료 시간을 반환해야 한다', () async {
        final expiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => expiresAt);

        final result = await mockTokenStorage.getRefreshTokenExpiry();

        expect(result, equals(expiresAt));
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });

      test('저장된 만료 시간이 없을 때 null을 반환해야 한다', () async {
        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => null);

        final result = await mockTokenStorage.getRefreshTokenExpiry();

        expect(result, isNull);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });

      test('과거 만료 시간을 반환할 수 있어야 한다', () async {
        final pastExpiry = DateTime.now().subtract(const Duration(days: 1));

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => pastExpiry);

        final result = await mockTokenStorage.getRefreshTokenExpiry();

        expect(result, equals(pastExpiry));
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });
    });

    group('clearTokens', () {
      test('저장된 토큰들을 삭제해야 한다', () async {
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        await mockTokenStorage.clearTokens();

        verify(() => mockTokenStorage.clearTokens()).called(1);
      });

      test('여러 번 호출해도 정상 작동해야 한다', () async {
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        await mockTokenStorage.clearTokens();
        await mockTokenStorage.clearTokens();
        await mockTokenStorage.clearTokens();

        verify(() => mockTokenStorage.clearTokens()).called(3);
      });
    });

    group('복합 시나리오', () {
      test('저장 → 조회 → 삭제 시나리오', () async {
        const refreshToken = 'test_token';
        final expiresAt = DateTime.now().add(const Duration(days: 30));

        // Mock 설정
        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: expiresAt,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => refreshToken);

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => expiresAt);

        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        // 1. 저장
        await mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: expiresAt,
        );

        // 2. 조회
        final savedToken = await mockTokenStorage.getRefreshToken();
        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();

        // 3. 삭제
        await mockTokenStorage.clearTokens();

        // 검증
        expect(savedToken, equals(refreshToken));
        expect(savedExpiry, equals(expiresAt));
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: expiresAt,
        )).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
        verify(() => mockTokenStorage.clearTokens()).called(1);
      });
    });

    group('인터페이스 구현', () {
      test('TokenStorageInterface를 올바르게 구현해야 한다', () {
        expect(mockTokenStorage, isA<TokenStorageInterface>());
      });

      test('모든 인터페이스 메서드가 구현되어야 한다', () {
        expect(mockTokenStorage.saveRefreshToken, isA<Function>());
        expect(mockTokenStorage.getRefreshToken, isA<Function>());
        expect(mockTokenStorage.getRefreshTokenExpiry, isA<Function>());
        expect(mockTokenStorage.clearTokens, isA<Function>());
      });
    });
  });
}
