import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/fake_data/fake_data_generator.dart';

void main() {
  group('AuthenticationResult', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        // Given
        const status = AuthenticationStatus.authenticated;

        // When
        const result = AuthenticationResult(status: status);

        // Then
        expect(result.status, equals(AuthenticationStatus.authenticated));
        expect(result.token, isNull);
        expect(result.message, isNull);
      });

      test('토큰과 메시지가 포함된 생성자가 올바르게 작동해야 한다', () {
        // Given
        final token = FakeDataGenerator.createValidAuthToken();
        final message = faker.lorem.sentence();

        // When
        final result = AuthenticationResult(
          status: AuthenticationStatus.authenticated,
          token: token,
          message: message,
        );

        // Then
        expect(result.status, equals(AuthenticationStatus.authenticated));
        expect(result.token, equals(token));
        expect(result.message, equals(message));
      });
    });

    group('Factory 생성자', () {
      test('authenticated factory가 올바르게 작동해야 한다', () {
        // Given
        final token = FakeDataGenerator.createValidAuthToken();

        // When
        final result = AuthenticationResult.authenticated(token);

        // Then
        expect(result.status, equals(AuthenticationStatus.authenticated));
        expect(result.token, equals(token));
        expect(result.message, isNull);
      });

      test('unauthenticated factory가 기본 메시지로 올바르게 작동해야 한다', () {
        // When
        final result = AuthenticationResult.unauthenticated();

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        expect(result.token, isNull);
        expect(result.message, equals('Authentication required'));
      });

      test('unauthenticated factory가 커스텀 메시지로 올바르게 작동해야 한다', () {
        // Given
        final customMessage = faker.lorem.sentence();

        // When
        final result = AuthenticationResult.unauthenticated(customMessage);

        // Then
        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        expect(result.token, isNull);
        expect(result.message, equals(customMessage));
      });

      test('expired factory가 기본 메시지로 올바르게 작동해야 한다', () {
        // When
        final result = AuthenticationResult.expired();

        // Then
        expect(result.status, equals(AuthenticationStatus.expired));
        expect(result.token, isNull);
        expect(result.message, equals('Token expired'));
      });

      test('expired factory가 커스텀 메시지로 올바르게 작동해야 한다', () {
        // Given
        final customMessage = faker.lorem.sentence();

        // When
        final result = AuthenticationResult.expired(customMessage);

        // Then
        expect(result.status, equals(AuthenticationStatus.expired));
        expect(result.token, isNull);
        expect(result.message, equals(customMessage));
      });
    });

    group('비즈니스 로직', () {
      test('인증된 상태에서 isAuthenticated가 true를 반환해야 한다', () {
        // Given
        final token = FakeDataGenerator.createValidAuthToken();

        // When
        final result = AuthenticationResult.authenticated(token);

        // Then
        expect(result.isAuthenticated(), isTrue);
      });

      test('인증되지 않은 상태에서 isAuthenticated가 false를 반환해야 한다', () {
        // When
        final result = AuthenticationResult.unauthenticated();

        // Then
        expect(result.isAuthenticated(), isFalse);
      });

      test('만료된 상태에서 isAuthenticated가 false를 반환해야 한다', () {
        // When
        final result = AuthenticationResult.expired();

        // Then
        expect(result.isAuthenticated(), isFalse);
      });

      test('토큰 정보를 올바르게 반환해야 한다', () {
        // Given
        final token = FakeDataGenerator.createValidAuthToken();

        // When
        final result = AuthenticationResult.authenticated(token);

        // Then
        expect(result.token, equals(token));
        expect(result.token?.accessToken, equals(token.accessToken));
        expect(result.token?.refreshToken, equals(token.refreshToken));
      });
    });

    group('Equatable 구현', () {
      test('동일한 값으로 생성된 객체는 같아야 한다', () {
        // Given
        final token = FakeDataGenerator.createValidAuthToken();

        // When
        final result1 = AuthenticationResult.authenticated(token);
        final result2 = AuthenticationResult.authenticated(token);

        // Then
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('다른 상태로 생성된 객체는 달라야 한다', () {
        // Given
        final token = FakeDataGenerator.createValidAuthToken();

        // When
        final authenticatedResult = AuthenticationResult.authenticated(token);
        final unauthenticatedResult = AuthenticationResult.unauthenticated();

        // Then
        expect(authenticatedResult, isNot(equals(unauthenticatedResult)));
      });

      test('다른 메시지로 생성된 객체는 달라야 한다', () {
        // Given
        final message1 = faker.lorem.sentence();
        final message2 = faker.lorem.sentence();

        // When
        final result1 = AuthenticationResult.unauthenticated(message1);
        final result2 = AuthenticationResult.unauthenticated(message2);

        // Then
        expect(result1, isNot(equals(result2)));
      });

      test('다른 토큰으로 생성된 객체는 달라야 한다', () {
        // Given
        final token1 = FakeDataGenerator.createValidAuthToken();
        final token2 = FakeDataGenerator.createValidAuthToken(); // 다른 토큰

        // When
        final result1 = AuthenticationResult.authenticated(token1);
        final result2 = AuthenticationResult.authenticated(token2);

        // Then
        expect(result1, isNot(equals(result2)));
      });
    });

    group('AuthenticationStatus enum', () {
      test('모든 상태 값이 올바르게 정의되어야 한다', () {
        // Then
        expect(AuthenticationStatus.values, hasLength(3));
        expect(AuthenticationStatus.values, contains(AuthenticationStatus.authenticated));
        expect(AuthenticationStatus.values, contains(AuthenticationStatus.unauthenticated));
        expect(AuthenticationStatus.values, contains(AuthenticationStatus.expired));
      });
    });
  });
}
