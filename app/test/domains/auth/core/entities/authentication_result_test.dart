import 'package:flutter_test/flutter_test.dart';

import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/entities/authentication_result.dart';
import '../../../../utils/fake_data_generator.dart';

void main() {
  group('AuthenticationResult', () {
    late AuthToken validToken;

    setUp(() {
      validToken = FakeDataGenerator.createValidAuthToken();
    });

    group('authenticated factory', () {
      test('인증된 상태로 생성되어야 한다', () {
        final result = AuthenticationResult.authenticated(validToken);

        expect(result.status, equals(AuthenticationStatus.authenticated));
        expect(result.token, equals(validToken));
        expect(result.message, isNull);
      });

      test('토큰 정보가 올바르게 저장되어야 한다', () {
        final result = AuthenticationResult.authenticated(validToken);

        expect(result.token?.accessToken, isNotEmpty);
        expect(result.token?.refreshToken, isNotEmpty);
      });
    });

    group('unauthenticated factory', () {
      test('메시지 없이 미인증 상태로 생성되어야 한다', () {
        final result = AuthenticationResult.unauthenticated();

        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        expect(result.token, isNull);
        expect(result.message, equals('Authentication required'));
      });

      test('커스텀 메시지로 미인증 상태를 생성해야 한다', () {
        final customMessage = 'Invalid credentials';
        final result = AuthenticationResult.unauthenticated(customMessage);

        expect(result.status, equals(AuthenticationStatus.unauthenticated));
        expect(result.token, isNull);
        expect(result.message, equals(customMessage));
      });
    });

    group('expired factory', () {
      test('메시지 없이 만료 상태로 생성되어야 한다', () {
        final result = AuthenticationResult.expired();

        expect(result.status, equals(AuthenticationStatus.expired));
        expect(result.token, isNull);
        expect(result.message, equals('Token expired'));
      });

      test('커스텀 메시지로 만료 상태를 생성해야 한다', () {
        final customMessage = 'Access token has expired';
        final result = AuthenticationResult.expired(customMessage);

        expect(result.status, equals(AuthenticationStatus.expired));
        expect(result.token, isNull);
        expect(result.message, equals(customMessage));
      });
    });

    group('isAuthenticated method', () {
      test('인증된 상태일 때 true를 반환해야 한다', () {
        final result = AuthenticationResult.authenticated(validToken);

        expect(result.isAuthenticated(), isTrue);
      });

      test('미인증 상태일 때 false를 반환해야 한다', () {
        final result = AuthenticationResult.unauthenticated();

        expect(result.isAuthenticated(), isFalse);
      });

      test('만료 상태일 때 false를 반환해야 한다', () {
        final result = AuthenticationResult.expired();

        expect(result.isAuthenticated(), isFalse);
      });
    });

    group('Equatable 구현', () {
      test('동일한 상태와 토큰을 가진 결과는 같아야 한다', () {
        final result1 = AuthenticationResult.authenticated(validToken);
        final result2 = AuthenticationResult.authenticated(validToken);

        expect(result1, equals(result2));
      });

      test('다른 상태를 가진 결과는 달라야 한다', () {
        final authenticated = AuthenticationResult.authenticated(validToken);
        final unauthenticated = AuthenticationResult.unauthenticated();

        expect(authenticated, isNot(equals(unauthenticated)));
      });

      test('다른 메시지를 가진 결과는 달라야 한다', () {
        final result1 = AuthenticationResult.unauthenticated('Message 1');
        final result2 = AuthenticationResult.unauthenticated('Message 2');

        expect(result1, isNot(equals(result2)));
      });

      test('다른 토큰을 가진 결과는 달라야 한다', () {
        final token1 = AuthToken(
          accessToken: 'token1',
          refreshToken: 'refresh1',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 30)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final token2 = AuthToken(
          accessToken: 'token2',
          refreshToken: 'refresh2',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 30)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );

        final result1 = AuthenticationResult.authenticated(token1);
        final result2 = AuthenticationResult.authenticated(token2);

        expect(result1, isNot(equals(result2)));
      });
    });

    group('props', () {
      test('상태, 토큰, 메시지를 포함해야 한다', () {
        final result = AuthenticationResult.authenticated(validToken);

        expect(result.props, containsAll([
          AuthenticationStatus.authenticated,
          validToken,
          null, // message
        ]));
      });

      test('메시지가 있는 경우 props에 포함되어야 한다', () {
        final result = AuthenticationResult.unauthenticated('Custom message');

        expect(result.props, containsAll([
          AuthenticationStatus.unauthenticated,
          null, // token
          'Custom message',
        ]));
      });
    });

    group('상태별 데이터 접근', () {
      test('인증된 상태에서 토큰에 안전하게 접근할 수 있어야 한다', () {
        final result = AuthenticationResult.authenticated(validToken);

        expect(result.token?.accessToken, isNotEmpty);
        expect(result.token?.refreshToken, isNotEmpty);
      });

      test('미인증 상태에서 토큰은 null이어야 한다', () {
        final result = AuthenticationResult.unauthenticated();

        expect(result.token, isNull);
      });

      test('만료 상태에서 토큰은 null이어야 한다', () {
        final result = AuthenticationResult.expired();

        expect(result.token, isNull);
      });
    });

    group('에러 메시지 처리', () {
      test('에러 메시지가 있는 경우 적절히 표시되어야 한다', () {
        final errorMessage = 'Network connection failed';
        final result = AuthenticationResult.unauthenticated(errorMessage);

        expect(result.message, equals(errorMessage));
      });

      test('기본 메시지가 없는 경우 기본값이 사용되어야 한다', () {
        final result = AuthenticationResult.unauthenticated();

        expect(result.message, equals('Authentication required'));
      });
    });
  });
}
