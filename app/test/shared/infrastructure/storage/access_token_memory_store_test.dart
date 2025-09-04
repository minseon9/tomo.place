import 'package:app/shared/infrastructure/storage/access_token_memory_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/test_times.dart';
import '../../../utils/time_test_utils.dart';

void main() {
  group('AccessTokenMemoryStore', () {
    test('returns false when empty', () {
      final store = AccessTokenMemoryStore();

      expect(store.hasValidToken, isFalse);
    });

    test('returns true when token not expired (시간 고정 테스트)', () async {
      await TimeTestUtils.withFrozenTime(TestTimes.fixedTime, () async {
        final store = AccessTokenMemoryStore();
        store.set('t', TestTimes.tokenValidTime);

        expect(store.hasValidToken, isTrue);
      });
    });

    test('returns false when expired (시간 고정 테스트)', () async {
      await TimeTestUtils.withFrozenTime(TestTimes.fixedTime, () async {
        final store = AccessTokenMemoryStore();
        store.set('t', TestTimes.tokenExpiredTime);

        expect(store.hasValidToken, isFalse);
      });
    });

    test('clear removes token and expiry', () async {
      await TimeTestUtils.withFrozenTime(TestTimes.fixedTime, () async {
        final store = AccessTokenMemoryStore();
        store.set('t', TestTimes.tokenValidTime);
        store.clear();

        expect(store.token, isNull);
        expect(store.expiresAt, isNull);
        expect(store.hasValidToken, isFalse);
      });
    });
  });
}
