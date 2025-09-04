import 'package:flutter_test/flutter_test.dart';

import 'package:app/domains/auth/data/oauth/oauth_result.dart';

void main() {
  group('OAuthResult', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        // Given & When
        const result = OAuthResult(
          success: true,
          cancelled: false,
          authorizationCode: 'test_auth_code',
          error: null,
          errorCode: null,
        );

        // Then
        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, equals('test_auth_code'));
        expect(result.error, isNull);
        expect(result.errorCode, isNull);
      });

      test('const 생성자로 생성되어야 한다', () {
        // Given & When
        const result = OAuthResult(
          success: false,
          cancelled: true,
          authorizationCode: null,
          error: 'Test error',
          errorCode: 'TEST_ERROR',
        );

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
        expect(result.authorizationCode, isNull);
        expect(result.error, equals('Test error'));
        expect(result.errorCode, equals('TEST_ERROR'));
      });
    });

    group('success factory', () {
      test('성공 결과를 올바르게 생성해야 한다', () {
        // Given & When
        final result = OAuthResult.success(
          authorizationCode: 'success_auth_code',
        );

        // Then
        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, equals('success_auth_code'));
        expect(result.error, isNull);
        expect(result.errorCode, isNull);
      });

      test('빈 authorization code로도 성공 결과를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult.success(authorizationCode: '');

        // Then
        expect(result.success, isTrue);
        expect(result.authorizationCode, equals(''));
      });
    });

    group('failure factory', () {
      test('실패 결과를 올바르게 생성해야 한다', () {
        // Given & When
        final result = OAuthResult.failure(
          error: 'Authentication failed',
          errorCode: 'AUTH_FAILED',
        );

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, isNull);
        expect(result.error, equals('Authentication failed'));
        expect(result.errorCode, equals('AUTH_FAILED'));
      });

      test('error code 없이 실패 결과를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult.failure(error: 'Network error');

        // Then
        expect(result.success, isFalse);
        expect(result.error, equals('Network error'));
        expect(result.errorCode, isNull);
      });

      test('빈 에러 메시지로도 실패 결과를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult.failure(error: '');

        // Then
        expect(result.success, isFalse);
        expect(result.error, equals(''));
      });
    });

    group('cancelled factory', () {
      test('취소 결과를 올바르게 생성해야 한다', () {
        // Given & When
        final result = OAuthResult.cancelled();

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
        expect(result.authorizationCode, isNull);
        expect(result.error, equals('User cancelled authentication'));
        expect(result.errorCode, equals('USER_CANCELLED'));
      });

      test('취소 결과는 항상 동일해야 한다', () {
        // Given & When
        final result1 = OAuthResult.cancelled();
        final result2 = OAuthResult.cancelled();

        // Then
        expect(result1.success, equals(result2.success));
        expect(result1.cancelled, equals(result2.cancelled));
        expect(result1.error, equals(result2.error));
        expect(result1.errorCode, equals(result2.errorCode));
      });
    });

    group('상태 확인', () {
      test('성공 상태를 올바르게 확인해야 한다', () {
        // Given
        final successResult = OAuthResult.success(authorizationCode: 'test_code');
        final failureResult = OAuthResult.failure(error: 'test_error');
        final cancelledResult = OAuthResult.cancelled();

        // When & Then
        expect(successResult.success, isTrue);
        expect(failureResult.success, isFalse);
        expect(cancelledResult.success, isFalse);
      });

      test('취소 상태를 올바르게 확인해야 한다', () {
        // Given
        final successResult = OAuthResult.success(authorizationCode: 'test_code');
        final failureResult = OAuthResult.failure(error: 'test_error');
        final cancelledResult = OAuthResult.cancelled();

        // When & Then
        expect(successResult.cancelled, isFalse);
        expect(failureResult.cancelled, isFalse);
        expect(cancelledResult.cancelled, isTrue);
      });
    });

    group('에지 케이스', () {
      test('모든 필드가 null인 결과를 생성할 수 있어야 한다', () {
        // Given & When
        const result = OAuthResult(
          success: false,
          cancelled: false,
          authorizationCode: null,
          error: null,
          errorCode: null,
        );

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, isNull);
        expect(result.error, isNull);
        expect(result.errorCode, isNull);
      });

      test('성공하면서 에러 메시지가 있는 결과를 생성할 수 있어야 한다', () {
        // Given & When
        const result = OAuthResult(
          success: true,
          cancelled: false,
          authorizationCode: 'test_code',
          error: 'Warning message',
          errorCode: 'WARNING',
        );

        // Then
        expect(result.success, isTrue);
        expect(result.authorizationCode, equals('test_code'));
        expect(result.error, equals('Warning message'));
        expect(result.errorCode, equals('WARNING'));
      });

      test('취소되면서 성공 상태인 결과를 생성할 수 있어야 한다', () {
        // Given & When
        const result = OAuthResult(
          success: true,
          cancelled: true,
          authorizationCode: 'test_code',
          error: null,
          errorCode: null,
        );

        // Then
        expect(result.success, isTrue);
        expect(result.cancelled, isTrue);
        expect(result.authorizationCode, equals('test_code'));
      });
    });

    group('불변성', () {
      test('생성 후 값이 변경되지 않아야 한다', () {
        // Given
        const result = OAuthResult(
          success: true,
          cancelled: false,
          authorizationCode: 'immutable_code',
          error: 'immutable_error',
          errorCode: 'IMMUTABLE',
        );

        // When & Then
        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, equals('immutable_code'));
        expect(result.error, equals('immutable_error'));
        expect(result.errorCode, equals('IMMUTABLE'));
      });
    });
  });
}
