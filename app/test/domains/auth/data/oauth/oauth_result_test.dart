import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';

import 'package:app/domains/auth/data/oauth/oauth_result.dart';

void main() {
  group('OAuthResult', () {
    late String authorizationCode;
    late String error;
    late String errorCode;

    setUp(() {
      authorizationCode = faker.guid.guid();
      error = faker.lorem.sentence();
      errorCode = faker.lorem.word();
    });

    group('생성자', () {
      test('기본 생성자로 OAuthResult를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult(
          success: true,
          cancelled: false,
          authorizationCode: authorizationCode,
          error: null,
          errorCode: null,
        );

        // Then
        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, equals(authorizationCode));
        expect(result.error, isNull);
        expect(result.errorCode, isNull);
      });

      test('모든 필드를 포함한 OAuthResult를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult(
          success: false,
          cancelled: true,
          authorizationCode: authorizationCode,
          error: error,
          errorCode: errorCode,
        );

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
        expect(result.authorizationCode, equals(authorizationCode));
        expect(result.error, equals(error));
        expect(result.errorCode, equals(errorCode));
      });

      test('cancelled 기본값이 false여야 한다', () {
        // Given & When
        final result = OAuthResult(success: true);

        // Then
        expect(result.cancelled, isFalse);
      });
    });

    group('success 팩토리', () {
      test('success 팩토리로 성공 결과를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult.success(authorizationCode: authorizationCode);

        // Then
        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, equals(authorizationCode));
        expect(result.error, isNull);
        expect(result.errorCode, isNull);
      });

      test('success 팩토리로 생성된 결과는 성공 상태여야 한다', () {
        // Given & When
        final result = OAuthResult.success(authorizationCode: authorizationCode);

        // Then
        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
      });
    });

    group('failure 팩토리', () {
      test('failure 팩토리로 실패 결과를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult.failure(error: error, errorCode: errorCode);

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, isNull);
        expect(result.error, equals(error));
        expect(result.errorCode, equals(errorCode));
      });

      test('failure 팩토리로 errorCode 없이 실패 결과를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult.failure(error: error);

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, isNull);
        expect(result.error, equals(error));
        expect(result.errorCode, isNull);
      });

      test('failure 팩토리로 생성된 결과는 실패 상태여야 한다', () {
        // Given & When
        final result = OAuthResult.failure(error: error);

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
      });
    });

    group('cancelled 팩토리', () {
      test('cancelled 팩토리로 취소 결과를 생성할 수 있어야 한다', () {
        // Given & When
        final result = OAuthResult.cancelled();

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
        expect(result.authorizationCode, isNull);
        expect(result.error, equals('User cancelled authentication'));
        expect(result.errorCode, equals('USER_CANCELLED'));
      });

      test('cancelled 팩토리로 생성된 결과는 취소 상태여야 한다', () {
        // Given & When
        final result = OAuthResult.cancelled();

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
        expect(result.error, equals('User cancelled authentication'));
        expect(result.errorCode, equals('USER_CANCELLED'));
      });
    });

    group('상태 검증', () {
      test('성공 결과는 success가 true여야 한다', () {
        // Given & When
        final result = OAuthResult.success(authorizationCode: authorizationCode);

        // Then
        expect(result.success, isTrue);
      });

      test('실패 결과는 success가 false여야 한다', () {
        // Given & When
        final result = OAuthResult.failure(error: error);

        // Then
        expect(result.success, isFalse);
      });

      test('취소 결과는 success가 false이고 cancelled가 true여야 한다', () {
        // Given & When
        final result = OAuthResult.cancelled();

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
      });
    });

    group('데이터 검증', () {
      test('성공 결과는 authorizationCode를 포함해야 한다', () {
        // Given & When
        final result = OAuthResult.success(authorizationCode: authorizationCode);

        // Then
        expect(result.authorizationCode, equals(authorizationCode));
        expect(result.authorizationCode, isNotEmpty);
      });

      test('실패 결과는 error를 포함해야 한다', () {
        // Given & When
        final result = OAuthResult.failure(error: error);

        // Then
        expect(result.error, equals(error));
        expect(result.error, isNotEmpty);
      });

      test('실패 결과는 선택적으로 errorCode를 포함할 수 있다', () {
        // Given & When
        final resultWithErrorCode = OAuthResult.failure(error: error, errorCode: errorCode);
        final resultWithoutErrorCode = OAuthResult.failure(error: error);

        // Then
        expect(resultWithErrorCode.errorCode, equals(errorCode));
        expect(resultWithoutErrorCode.errorCode, isNull);
      });

      test('취소 결과는 고정된 error와 errorCode를 포함해야 한다', () {
        // Given & When
        final result = OAuthResult.cancelled();

        // Then
        expect(result.error, equals('User cancelled authentication'));
        expect(result.errorCode, equals('USER_CANCELLED'));
      });
    });

    group('다양한 시나리오', () {
      test('네트워크 오류 시나리오', () {
        // Given & When
        final result = OAuthResult.failure(
          error: 'Network connection failed',
          errorCode: 'NETWORK_ERROR',
        );

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.error, equals('Network connection failed'));
        expect(result.errorCode, equals('NETWORK_ERROR'));
      });

      test('인증 실패 시나리오', () {
        // Given & When
        final result = OAuthResult.failure(
          error: 'Invalid credentials',
          errorCode: 'AUTH_FAILED',
        );

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.error, equals('Invalid credentials'));
        expect(result.errorCode, equals('AUTH_FAILED'));
      });

      test('사용자 취소 시나리오', () {
        // Given & When
        final result = OAuthResult.cancelled();

        // Then
        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
        expect(result.error, equals('User cancelled authentication'));
        expect(result.errorCode, equals('USER_CANCELLED'));
      });

      test('성공적인 인증 시나리오', () {
        // Given & When
        final result = OAuthResult.success(authorizationCode: 'auth_code_123');

        // Then
        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
        expect(result.authorizationCode, equals('auth_code_123'));
        expect(result.error, isNull);
        expect(result.errorCode, isNull);
      });
    });
  });
}