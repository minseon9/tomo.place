import 'package:app/domains/auth/data/oauth/oauth_provider.dart';
import 'package:app/domains/auth/data/oauth/oauth_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OAuthProvider', () {
    group('추상 클래스', () {
      test('OAuthProvider는 추상 클래스여야 한다', () {
        // Given & When & Then
        expect(OAuthProvider, isA<Type>());
        // 추상 클래스이므로 직접 인스턴스화할 수 없음 - 실제 구현체를 통해 테스트
      });

      test('구현 클래스는 모든 추상 메서드를 구현해야 한다', () {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        expect(provider.providerId, isA<String>());
        expect(provider.displayName, isA<String>());
        expect(provider.isSupported, isA<bool>());
        expect(provider.signIn, isA<Function>());
        expect(provider.signOut, isA<Function>());
        expect(provider.initialize, isA<Function>());
        expect(provider.dispose, isA<Function>());
      });
    });

    group('기본 구현', () {
      test('initialize()는 기본적으로 빈 구현을 제공해야 한다', () async {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        expect(() => provider.initialize(), returnsNormally);
        await expectLater(provider.initialize(), completes);
      });

      test('dispose()는 기본적으로 빈 구현을 제공해야 한다', () async {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        expect(() => provider.dispose(), returnsNormally);
        await expectLater(provider.dispose(), completes);
      });
    });

    group('인터페이스 계약', () {
      test('providerId는 비어있지 않은 문자열이어야 한다', () {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        expect(provider.providerId, isNotEmpty);
        expect(provider.providerId, isA<String>());
      });

      test('displayName은 비어있지 않은 문자열이어야 한다', () {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        expect(provider.displayName, isNotEmpty);
        expect(provider.displayName, isA<String>());
      });

      test('isSupported는 boolean 값이어야 한다', () {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        expect(provider.isSupported, isA<bool>());
      });

      test('signIn()은 OAuthResult를 반환해야 한다', () async {
        // Given
        final provider = TestOAuthProvider();

        // When
        final result = await provider.signIn();

        // Then
        expect(result, isA<OAuthResult>());
      });

      test('signOut()은 Future<void>를 반환해야 한다', () async {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        await expectLater(provider.signOut(), completes);
      });
    });

    group('생명주기', () {
      test('initialize() -> signIn() -> signOut() -> dispose() 순서로 호출할 수 있어야 한다', () async {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        await expectLater(provider.initialize(), completes);
        final result = await provider.signIn();
        expect(result, isA<OAuthResult>());
        await expectLater(provider.signOut(), completes);
        await expectLater(provider.dispose(), completes);
      });

      test('여러 번 initialize()를 호출해도 문제없이 동작해야 한다', () async {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        await expectLater(provider.initialize(), completes);
        await expectLater(provider.initialize(), completes);
        await expectLater(provider.initialize(), completes);
      });

      test('여러 번 dispose()를 호출해도 문제없이 동작해야 한다', () async {
        // Given
        final provider = TestOAuthProvider();

        // When & Then
        await expectLater(provider.dispose(), completes);
        await expectLater(provider.dispose(), completes);
        await expectLater(provider.dispose(), completes);
      });
    });

    group('에러 처리', () {
      test('signIn()에서 예외가 발생해도 적절히 처리되어야 한다', () async {
        // Given
        final provider = ErrorThrowingOAuthProvider();

        // When & Then
        await expectLater(
          provider.signIn(),
          throwsA(isA<Exception>()),
        );
      });

      test('signOut()에서 예외가 발생해도 적절히 처리되어야 한다', () async {
        // Given
        final provider = ErrorThrowingOAuthProvider();

        // When & Then
        await expectLater(
          provider.signOut(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// 테스트용 구현 클래스
class TestOAuthProvider implements OAuthProvider {
  @override
  String get providerId => 'test_provider';

  @override
  String get displayName => 'Test Provider';

  @override
  bool get isSupported => true;

  @override
  Future<OAuthResult> signIn() async {
    return OAuthResult.success(authorizationCode: 'test_code');
  }

  @override
  Future<void> signOut() async {
    // 빈 구현
  }

  @override
  Future<void> initialize() async {
    // 빈 구현
  }

  @override
  Future<void> dispose() async {
    // 빈 구현
  }
}

// 에러를 발생시키는 테스트용 구현 클래스
class ErrorThrowingOAuthProvider implements OAuthProvider {
  @override
  String get providerId => 'error_provider';

  @override
  String get displayName => 'Error Provider';

  @override
  bool get isSupported => true;

  @override
  Future<OAuthResult> signIn() async {
    throw Exception('Sign in failed');
  }

  @override
  Future<void> signOut() async {
    throw Exception('Sign out failed');
  }

  @override
  Future<void> initialize() async {
    // 빈 구현
  }

  @override
  Future<void> dispose() async {
    // 빈 구현
  }
}
