import 'package:tomo_place/shared/infrastructure/storage/access_token_memory_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccessTokenMemoryStore', () {
    late AccessTokenMemoryStore memoryStore;

    setUp(() {
      memoryStore = AccessTokenMemoryStore();
    });

    group('생성자', () {
      test('기본값으로 생성되어야 한다', () {
        expect(memoryStore.token, isNull);
        expect(memoryStore.expiresAt, isNull);
        expect(memoryStore.hasValidToken, isFalse);
      });
    });

    group('set 메서드', () {
      test('토큰과 만료 시간을 올바르게 저장해야 한다', () {
        const testToken = 'test_access_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);

        expect(memoryStore.token, equals(testToken));
        expect(memoryStore.expiresAt, equals(testExpiresAt));
      });

      test('기존 토큰을 덮어쓰기해야 한다', () {
        const firstToken = 'first_token';
        const secondToken = 'second_token';
        final firstExpiresAt = DateTime.now().add(const Duration(hours: 1));
        final secondExpiresAt = DateTime.now().add(const Duration(hours: 2));

        memoryStore.set(firstToken, firstExpiresAt);
        expect(memoryStore.token, equals(firstToken));
        expect(memoryStore.expiresAt, equals(firstExpiresAt));

        memoryStore.set(secondToken, secondExpiresAt);
        expect(memoryStore.token, equals(secondToken));
        expect(memoryStore.expiresAt, equals(secondExpiresAt));
      });

      test('빈 문자열 토큰을 저장할 수 있어야 한다', () {
        const emptyToken = '';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(emptyToken, testExpiresAt);

        expect(memoryStore.token, equals(emptyToken));
        expect(memoryStore.expiresAt, equals(testExpiresAt));
      });

      test('과거 만료 시간을 저장할 수 있어야 한다', () {
        const testToken = 'test_token';
        final pastExpiresAt = DateTime.now().subtract(const Duration(hours: 1));

        memoryStore.set(testToken, pastExpiresAt);

        expect(memoryStore.token, equals(testToken));
        expect(memoryStore.expiresAt, equals(pastExpiresAt));
        expect(memoryStore.hasValidToken, isFalse);
      });
    });

    group('token getter', () {
      test('저장된 토큰을 올바르게 반환해야 한다', () {
        const testToken = 'test_access_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);

        expect(memoryStore.token, equals(testToken));
      });

      test('저장된 토큰이 없을 때 null을 반환해야 한다', () {
        expect(memoryStore.token, isNull);
      });

      test('clear 후에 null을 반환해야 한다', () {
        const testToken = 'test_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);
        expect(memoryStore.token, equals(testToken));

        memoryStore.clear();
        expect(memoryStore.token, isNull);
      });
    });

    group('expiresAt getter', () {
      test('저장된 만료 시간을 올바르게 반환해야 한다', () {
        const testToken = 'test_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);

        expect(memoryStore.expiresAt, equals(testExpiresAt));
      });

      test('저장된 만료 시간이 없을 때 null을 반환해야 한다', () {
        expect(memoryStore.expiresAt, isNull);
      });

      test('clear 후에 null을 반환해야 한다', () {
        const testToken = 'test_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);
        expect(memoryStore.expiresAt, equals(testExpiresAt));

        memoryStore.clear();
        expect(memoryStore.expiresAt, isNull);
      });
    });

    group('hasValidToken getter', () {
      test('유효한 토큰이 있을 때 true를 반환해야 한다', () {
        const testToken = 'test_token';
        final futureExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, futureExpiresAt);

        expect(memoryStore.hasValidToken, isTrue);
      });

      test('토큰이 없을 때 false를 반환해야 한다', () {
        expect(memoryStore.hasValidToken, isFalse);
      });

      test('만료 시간이 없을 때 false를 반환해야 한다', () {
        const testToken = 'test_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);
        expect(memoryStore.hasValidToken, isTrue);

        // expiresAt을 null로 설정하는 것은 직접 불가능하므로 clear 후 재설정
        memoryStore.clear();
        expect(memoryStore.hasValidToken, isFalse);
      });

      test('만료된 토큰일 때 false를 반환해야 한다', () {
        const testToken = 'test_token';
        final pastExpiresAt = DateTime.now().subtract(const Duration(hours: 1));

        memoryStore.set(testToken, pastExpiresAt);

        expect(memoryStore.hasValidToken, isFalse);
      });

      test('현재 시간과 정확히 같은 만료 시간일 때 false를 반환해야 한다', () {
        const testToken = 'test_token';
        final nowExpiresAt = DateTime.now();

        memoryStore.set(testToken, nowExpiresAt);

        expect(memoryStore.hasValidToken, isFalse);
      });

      test('미래의 만료 시간일 때 true를 반환해야 한다', () {
        const testToken = 'test_token';
        final futureExpiresAt = DateTime.now().add(const Duration(seconds: 1));

        memoryStore.set(testToken, futureExpiresAt);

        expect(memoryStore.hasValidToken, isTrue);
      });
    });

    group('clear 메서드', () {
      test('저장된 토큰과 만료 시간을 모두 삭제해야 한다', () {
        const testToken = 'test_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);
        expect(memoryStore.token, equals(testToken));
        expect(memoryStore.expiresAt, equals(testExpiresAt));
        expect(memoryStore.hasValidToken, isTrue);

        memoryStore.clear();

        expect(memoryStore.token, isNull);
        expect(memoryStore.expiresAt, isNull);
        expect(memoryStore.hasValidToken, isFalse);
      });

      test('저장된 데이터가 없을 때도 정상 작동해야 한다', () {
        expect(() => memoryStore.clear(), returnsNormally);
        
        expect(memoryStore.token, isNull);
        expect(memoryStore.expiresAt, isNull);
        expect(memoryStore.hasValidToken, isFalse);
      });

      test('여러 번 호출해도 정상 작동해야 한다', () {
        const testToken = 'test_token';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(testToken, testExpiresAt);
        memoryStore.clear();
        memoryStore.clear();
        memoryStore.clear();

        expect(memoryStore.token, isNull);
        expect(memoryStore.expiresAt, isNull);
        expect(memoryStore.hasValidToken, isFalse);
      });
    });

    group('인스턴스 격리', () {
      test('여러 인스턴스 간 데이터가 공유되지 않아야 한다', () {
        final store1 = AccessTokenMemoryStore();
        final store2 = AccessTokenMemoryStore();

        const token1 = 'token1';
        const token2 = 'token2';
        final expiresAt1 = DateTime.now().add(const Duration(hours: 1));
        final expiresAt2 = DateTime.now().add(const Duration(hours: 2));

        store1.set(token1, expiresAt1);
        store2.set(token2, expiresAt2);

        expect(store1.token, equals(token1));
        expect(store1.expiresAt, equals(expiresAt1));
        expect(store2.token, equals(token2));
        expect(store2.expiresAt, equals(expiresAt2));

        expect(store1.token, isNot(equals(store2.token)));
        expect(store1.expiresAt, isNot(equals(store2.expiresAt)));
      });

      test('한 인스턴스의 clear가 다른 인스턴스에 영향을 주지 않아야 한다', () {
        final store1 = AccessTokenMemoryStore();
        final store2 = AccessTokenMemoryStore();

        const token1 = 'token1';
        const token2 = 'token2';
        final expiresAt1 = DateTime.now().add(const Duration(hours: 1));
        final expiresAt2 = DateTime.now().add(const Duration(hours: 2));

        store1.set(token1, expiresAt1);
        store2.set(token2, expiresAt2);

        store1.clear();

        expect(store1.token, isNull);
        expect(store1.expiresAt, isNull);
        expect(store2.token, equals(token2));
        expect(store2.expiresAt, equals(expiresAt2));
      });
    });

    group('경계값 테스트', () {
      test('매우 긴 토큰을 저장할 수 있어야 한다', () {
        final longToken = 'a' * 10000;
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(longToken, testExpiresAt);

        expect(memoryStore.token, equals(longToken));
        expect(memoryStore.expiresAt, equals(testExpiresAt));
      });

      test('특수 문자가 포함된 토큰을 저장할 수 있어야 한다', () {
        const specialToken = 'token!@#\$%^&*()_+-=[]{}|;:,.<>?';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(specialToken, testExpiresAt);

        expect(memoryStore.token, equals(specialToken));
        expect(memoryStore.expiresAt, equals(testExpiresAt));
      });

      test('유니코드 문자가 포함된 토큰을 저장할 수 있어야 한다', () {
        const unicodeToken = '토큰🚀한글';
        final testExpiresAt = DateTime.now().add(const Duration(hours: 1));

        memoryStore.set(unicodeToken, testExpiresAt);

        expect(memoryStore.token, equals(unicodeToken));
        expect(memoryStore.expiresAt, equals(testExpiresAt));
      });
    });

    group('복합 시나리오', () {
      test('토큰 저장 → 유효성 확인 → 만료 → 재저장 시나리오', () {
        const testToken = 'test_token';
        final futureExpiresAt = DateTime.now().add(const Duration(hours: 1));

        // 1. 토큰 저장
        memoryStore.set(testToken, futureExpiresAt);
        expect(memoryStore.hasValidToken, isTrue);

        // 2. 만료된 토큰으로 덮어쓰기
        final pastExpiresAt = DateTime.now().subtract(const Duration(hours: 1));
        memoryStore.set(testToken, pastExpiresAt);
        expect(memoryStore.hasValidToken, isFalse);

        // 3. 새로운 유효한 토큰으로 재저장
        const newToken = 'new_token';
        final newExpiresAt = DateTime.now().add(const Duration(hours: 2));
        memoryStore.set(newToken, newExpiresAt);
        expect(memoryStore.hasValidToken, isTrue);
        expect(memoryStore.token, equals(newToken));
      });

      test('여러 번의 set과 clear 반복 시나리오', () {
        for (int i = 0; i < 10; i++) {
          final token = 'token_$i';
          final expiresAt = DateTime.now().add(Duration(hours: i + 1));

          memoryStore.set(token, expiresAt);
          expect(memoryStore.token, equals(token));
          expect(memoryStore.hasValidToken, isTrue);

          memoryStore.clear();
          expect(memoryStore.token, isNull);
          expect(memoryStore.hasValidToken, isFalse);
        }
      });
    });
  });
}
