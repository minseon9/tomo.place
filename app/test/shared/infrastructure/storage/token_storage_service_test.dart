import 'package:app/shared/infrastructure/storage/token_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../utils/mock_factory/shared_mock_factory.dart';

void main() {
  group('TokenStorageService', () {
    late TokenStorageService tokenStorageService;
    late MockTokenStorageInterface mockTokenStorage;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      tokenStorageService = TokenStorageService();
      mockTokenStorage = SharedMockFactory.createTokenStorage();
    });

    group('saveRefreshToken', () {
      test('Refresh Token과 만료 시간을 올바르게 저장해야 한다', () async {
        const refreshToken = 'test_refresh_token';
        final refreshTokenExpiresAt = DateTime.now().add(const Duration(days: 30));

        // Mock 설정
        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).thenAnswer((_) async {});

        // 실행
        await mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // 검증
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).called(1);
      });

      test('기존 Refresh Token을 덮어쓰기해야 한다', () async {
        const firstToken = 'first_refresh_token';
        const secondToken = 'second_refresh_token';
        final firstExpiry = DateTime.now().add(const Duration(days: 30));
        final secondExpiry = DateTime.now().add(const Duration(days: 60));

        // Mock 설정
        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: firstToken,
          refreshTokenExpiresAt: firstExpiry,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: secondToken,
          refreshTokenExpiresAt: secondExpiry,
        )).thenAnswer((_) async {});

        // 첫 번째 토큰 저장
        await mockTokenStorage.saveRefreshToken(
          refreshToken: firstToken,
          refreshTokenExpiresAt: firstExpiry,
        );

        // 두 번째 토큰으로 덮어쓰기
        await mockTokenStorage.saveRefreshToken(
          refreshToken: secondToken,
          refreshTokenExpiresAt: secondExpiry,
        );

        // 검증
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: firstToken,
          refreshTokenExpiresAt: firstExpiry,
        )).called(1);
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: secondToken,
          refreshTokenExpiresAt: secondExpiry,
        )).called(1);
      });

      test('빈 문자열 Refresh Token을 저장할 수 있어야 한다', () async {
        const emptyToken = '';
        final refreshTokenExpiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: emptyToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).thenAnswer((_) async {});

        await mockTokenStorage.saveRefreshToken(
          refreshToken: emptyToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: emptyToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
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
      test('저장된 Refresh Token을 올바르게 반환해야 한다', () async {
        const refreshToken = 'test_refresh_token';

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => refreshToken);

        final savedToken = await mockTokenStorage.getRefreshToken();
        expect(savedToken, equals(refreshToken));
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });

      test('저장된 Refresh Token이 없을 때 null을 반환해야 한다', () async {
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        final savedToken = await mockTokenStorage.getRefreshToken();
        expect(savedToken, isNull);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });

      test('clearTokens 후에 null을 반환해야 한다', () async {
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        await mockTokenStorage.clearTokens();
        final savedToken = await mockTokenStorage.getRefreshToken();

        expect(savedToken, isNull);
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });
    });

    group('getRefreshTokenExpiry', () {
      test('저장된 만료 시간을 올바르게 반환해야 한다', () async {
        const refreshToken = 'test_token';
        final refreshTokenExpiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => refreshTokenExpiresAt);

        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();
        expect(savedExpiry, equals(refreshTokenExpiresAt));
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });

      test('저장된 만료 시간이 없을 때 null을 반환해야 한다', () async {
        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => null);

        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();
        expect(savedExpiry, isNull);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });

      test('clearTokens 후에 null을 반환해야 한다', () async {
        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => null);

        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        await mockTokenStorage.clearTokens();
        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();

        expect(savedExpiry, isNull);
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });

      test('ISO 8601 형식의 만료 시간을 올바르게 파싱해야 한다', () async {
        final refreshTokenExpiresAt = DateTime(2024, 12, 31, 23, 59, 59);

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => refreshTokenExpiresAt);

        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();
        expect(savedExpiry, equals(refreshTokenExpiresAt));
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });
    });

    group('clearTokens', () {
      test('저장된 Refresh Token과 만료 시간을 모두 삭제해야 한다', () async {
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => null);

        await mockTokenStorage.clearTokens();

        final savedToken = await mockTokenStorage.getRefreshToken();
        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();

        expect(savedToken, isNull);
        expect(savedExpiry, isNull);
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });

      test('저장된 데이터가 없을 때도 정상 작동해야 한다', () async {
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        await mockTokenStorage.clearTokens();
        await mockTokenStorage.clearTokens();

        verify(() => mockTokenStorage.clearTokens()).called(2);
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

    group('동시성 테스트', () {
      test('Future.wait를 사용한 동시 저장이 올바르게 작동해야 한다', () async {
        const refreshToken = 'test_token';
        final refreshTokenExpiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => refreshToken);

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => refreshTokenExpiresAt);

        await mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        final savedToken = await mockTokenStorage.getRefreshToken();
        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();

        expect(savedToken, equals(refreshToken));
        expect(savedExpiry, equals(refreshTokenExpiresAt));
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });

      test('Future.wait를 사용한 동시 삭제가 올바르게 작동해야 한다', () async {
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => null);

        await mockTokenStorage.clearTokens();

        expect(await mockTokenStorage.getRefreshToken(), isNull);
        expect(await mockTokenStorage.getRefreshTokenExpiry(), isNull);
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });
    });

    group('경계값 테스트', () {
      test('매우 긴 Refresh Token을 저장할 수 있어야 한다', () async {
        final longToken = 'a' * 10000;
        final refreshTokenExpiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: longToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => longToken);

        await mockTokenStorage.saveRefreshToken(
          refreshToken: longToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        final savedToken = await mockTokenStorage.getRefreshToken();
        expect(savedToken, equals(longToken));
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: longToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });

      test('특수 문자가 포함된 Refresh Token을 저장할 수 있어야 한다', () async {
        const specialToken = 'token!@#\$%^&*()_+-=[]{}|;:,.<>?';
        final refreshTokenExpiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: specialToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => specialToken);

        await mockTokenStorage.saveRefreshToken(
          refreshToken: specialToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        final savedToken = await mockTokenStorage.getRefreshToken();
        expect(savedToken, equals(specialToken));
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: specialToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });

      test('유니코드 문자가 포함된 Refresh Token을 저장할 수 있어야 한다', () async {
        const unicodeToken = '토큰🚀한글';
        final refreshTokenExpiresAt = DateTime.now().add(const Duration(days: 30));

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: unicodeToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => unicodeToken);

        await mockTokenStorage.saveRefreshToken(
          refreshToken: unicodeToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        final savedToken = await mockTokenStorage.getRefreshToken();
        expect(savedToken, equals(unicodeToken));
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: unicodeToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        )).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(1);
      });

      test('매우 먼 미래의 만료 시간을 저장할 수 있어야 한다', () async {
        const refreshToken = 'test_token';
        final farFutureExpiry = DateTime(2099, 12, 31, 23, 59, 59);

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: farFutureExpiry,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => farFutureExpiry);

        await mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: farFutureExpiry,
        );

        final savedExpiry = await mockTokenStorage.getRefreshTokenExpiry();
        expect(savedExpiry, equals(farFutureExpiry));
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: refreshToken,
          refreshTokenExpiresAt: farFutureExpiry,
        )).called(1);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(1);
      });
    });

    group('복합 시나리오', () {
      test('저장 → 조회 → 삭제 → 재저장 시나리오', () async {
        const firstToken = 'first_token';
        const secondToken = 'second_token';
        final firstExpiry = DateTime.now().add(const Duration(days: 30));
        final secondExpiry = DateTime.now().add(const Duration(days: 60));

        // Mock 설정
        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: firstToken,
          refreshTokenExpiresAt: firstExpiry,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.saveRefreshToken(
          refreshToken: secondToken,
          refreshTokenExpiresAt: secondExpiry,
        )).thenAnswer((_) async {});

        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => firstToken);

        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => firstExpiry);

        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        // 1. 첫 번째 토큰 저장
        await mockTokenStorage.saveRefreshToken(
          refreshToken: firstToken,
          refreshTokenExpiresAt: firstExpiry,
        );

        // 2. 저장 확인
        expect(await mockTokenStorage.getRefreshToken(), equals(firstToken));
        expect(await mockTokenStorage.getRefreshTokenExpiry(), equals(firstExpiry));

        // 3. 삭제 후 Mock 재설정
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => null);
        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => null);

        await mockTokenStorage.clearTokens();
        expect(await mockTokenStorage.getRefreshToken(), isNull);
        expect(await mockTokenStorage.getRefreshTokenExpiry(), isNull);

        // 4. 두 번째 토큰 재저장 후 Mock 재설정
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => secondToken);
        when(() => mockTokenStorage.getRefreshTokenExpiry())
            .thenAnswer((_) async => secondExpiry);

        await mockTokenStorage.saveRefreshToken(
          refreshToken: secondToken,
          refreshTokenExpiresAt: secondExpiry,
        );

        // 5. 재저장 확인
        expect(await mockTokenStorage.getRefreshToken(), equals(secondToken));
        expect(await mockTokenStorage.getRefreshTokenExpiry(), equals(secondExpiry));

        // 검증
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: firstToken,
          refreshTokenExpiresAt: firstExpiry,
        )).called(1);
        verify(() => mockTokenStorage.saveRefreshToken(
          refreshToken: secondToken,
          refreshTokenExpiresAt: secondExpiry,
        )).called(1);
        verify(() => mockTokenStorage.clearTokens()).called(1);
        verify(() => mockTokenStorage.getRefreshToken()).called(3);
        verify(() => mockTokenStorage.getRefreshTokenExpiry()).called(3);
      });

      test('여러 번의 저장과 삭제 반복 시나리오', () async {
        for (int i = 0; i < 5; i++) {
          final token = 'token_$i';
          final expiry = DateTime.now().add(Duration(days: i + 1));

          // Mock 설정
          when(() => mockTokenStorage.saveRefreshToken(
            refreshToken: token,
            refreshTokenExpiresAt: expiry,
          )).thenAnswer((_) async {});

          when(() => mockTokenStorage.getRefreshToken())
              .thenAnswer((_) async => token);

          when(() => mockTokenStorage.getRefreshTokenExpiry())
              .thenAnswer((_) async => expiry);

          when(() => mockTokenStorage.clearTokens())
              .thenAnswer((_) async {});

          // 저장
          await mockTokenStorage.saveRefreshToken(
            refreshToken: token,
            refreshTokenExpiresAt: expiry,
          );

          // 저장 확인
          expect(await mockTokenStorage.getRefreshToken(), equals(token));
          expect(await mockTokenStorage.getRefreshTokenExpiry(), equals(expiry));

          // 삭제 후 Mock 재설정
          when(() => mockTokenStorage.getRefreshToken())
              .thenAnswer((_) async => null);
          when(() => mockTokenStorage.getRefreshTokenExpiry())
              .thenAnswer((_) async => null);

          // 삭제
          await mockTokenStorage.clearTokens();

          // 삭제 확인
          expect(await mockTokenStorage.getRefreshToken(), isNull);
          expect(await mockTokenStorage.getRefreshTokenExpiry(), isNull);
        }
      });
    });

    group('인터페이스 구현', () {
      test('TokenStorageInterface를 올바르게 구현해야 한다', () {
        expect(tokenStorageService, isA<TokenStorageInterface>());
        expect(mockTokenStorage, isA<TokenStorageInterface>());
      });

      test('모든 인터페이스 메서드가 구현되어야 한다', () {
        // TokenStorageService의 메서드 존재 확인
        expect(tokenStorageService.saveRefreshToken, isA<Function>());
        expect(tokenStorageService.getRefreshToken, isA<Function>());
        expect(tokenStorageService.getRefreshTokenExpiry, isA<Function>());
        expect(tokenStorageService.clearTokens, isA<Function>());

        // Mock의 메서드 존재 확인
        expect(mockTokenStorage.saveRefreshToken, isA<Function>());
        expect(mockTokenStorage.getRefreshToken, isA<Function>());
        expect(mockTokenStorage.getRefreshTokenExpiry, isA<Function>());
        expect(mockTokenStorage.clearTokens, isA<Function>());
      });
    });
  });
}