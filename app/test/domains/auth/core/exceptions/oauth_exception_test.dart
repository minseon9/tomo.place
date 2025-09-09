import 'package:tomo_place/domains/auth/core/exceptions/oauth_exception.dart';
import 'package:tomo_place/domains/auth/core/exceptions/error_codes.dart';
import 'package:tomo_place/domains/auth/core/exceptions/error_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';
import '../../../../utils/fake_data/fake_exception_generator.dart';

void main() {
  group('OAuthException', () {
    group('생성자', () {
      test('signOutFailed 생성자가 올바르게 작동해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);

        // When
        final exception = OAuthException.signOutFailed(
          message: message,
          provider: provider,
        );

        // Then
        expect(exception.message, equals('OAuth sign out exception raised: $message'));
        expect(exception.userMessage, equals('로그아웃이 실패했습니다.'));
        expect(exception.title, equals('로그아웃 오류'));
        expect(exception.errorType, equals(AuthErrorTypes.oauth));
        expect(exception.errorCode, equals(AuthErrorCodes.oauthSignOutFailed));
        expect(exception.suggestedAction, equals('다시 시도해주세요.'));
        expect(exception.provider, equals(provider));
      });

      test('authenticationFailed 생성자가 올바르게 작동해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);

        // When
        final exception = OAuthException.authenticationFailed(
          message: message,
          provider: provider,
        );

        // Then
        expect(exception.message, equals('OAuth exception raised: $message'));
        expect(exception.userMessage, equals('인증이 실패했습니다.'));
        expect(exception.title, equals('인증 오류'));
        expect(exception.errorType, equals(AuthErrorTypes.oauth));
        expect(exception.errorCode, equals(AuthErrorCodes.oauthAuthenticationFailed));
        expect(exception.suggestedAction, equals('다시 로그인해주세요.'));
        expect(exception.provider, equals(provider));
      });

      test('tokenRefreshFailed 생성자가 올바르게 작동해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);

        // When
        final exception = OAuthException.tokenRefreshFailed(
          message: message,
          provider: provider,
        );

        // Then
        expect(exception.message, equals('Token refresh failed: $message'));
        expect(exception.userMessage, equals('토큰 갱신에 실패했습니다.'));
        expect(exception.title, equals('토큰 오류'));
        expect(exception.errorType, equals(AuthErrorTypes.token));
        expect(exception.errorCode, equals(AuthErrorCodes.tokenRefreshFailed));
        expect(exception.suggestedAction, equals('다시 로그인해주세요.'));
        expect(exception.provider, equals(provider));
      });

      test('providerError 생성자가 올바르게 작동해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);

        // When
        final exception = OAuthException.providerError(
          message: message,
          provider: provider,
        );

        // Then
        expect(exception.message, equals('OAuth provider error: $message'));
        expect(exception.userMessage, equals('로그인 제공자에서 오류가 발생했습니다.'));
        expect(exception.title, equals('제공자 오류'));
        expect(exception.errorType, equals(AuthErrorTypes.provider));
        expect(exception.errorCode, equals(AuthErrorCodes.oauthProviderError));
        expect(exception.suggestedAction, equals('다른 방법으로 로그인하거나 잠시 후 다시 시도해주세요.'));
        expect(exception.provider, equals(provider));
      });

      test('invalidResponse 생성자가 올바르게 작동해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);

        // When
        final exception = OAuthException.invalidResponse(
          message: message,
          provider: provider,
        );

        // Then
        expect(exception.message, equals('Invalid OAuth response: $message'));
        expect(exception.userMessage, equals('로그인 응답을 처리할 수 없습니다.'));
        expect(exception.title, equals('응답 오류'));
        expect(exception.errorType, equals(AuthErrorTypes.oauth));
        expect(exception.errorCode, equals(AuthErrorCodes.oauthInvalidResponse));
        expect(exception.suggestedAction, equals('다시 시도해주세요.'));
        expect(exception.provider, equals(provider));
      });

      test('networkError 생성자가 올바르게 작동해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);

        // When
        final exception = OAuthException.networkError(
          message: message,
          provider: provider,
        );

        // Then
        expect(exception.message, equals('OAuth network error: $message'));
        expect(exception.userMessage, equals('네트워크 오류로 로그인할 수 없습니다.'));
        expect(exception.title, equals('네트워크 오류'));
        expect(exception.errorType, equals(AuthErrorTypes.oauth));
        expect(exception.errorCode, equals(AuthErrorCodes.oauthNetworkError));
        expect(exception.suggestedAction, equals('네트워크 연결을 확인하고 다시 시도해주세요.'));
        expect(exception.provider, equals(provider));
      });

      test('기본 생성자가 올바르게 작동해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final userMessage = faker.lorem.sentence();
        final title = faker.lorem.word();
        final errorType = faker.lorem.word();
        final errorCode = faker.lorem.word();
        final suggestedAction = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);

        // When
        final exception = OAuthException(
          message: message,
          userMessage: userMessage,
          title: title,
          errorType: errorType,
          errorCode: errorCode,
          suggestedAction: suggestedAction,
          provider: provider,
        );

        // Then
        expect(exception.message, equals(message));
        expect(exception.userMessage, equals(userMessage));
        expect(exception.title, equals(title));
        expect(exception.errorType, equals(errorType));
        expect(exception.errorCode, equals(errorCode));
        expect(exception.suggestedAction, equals(suggestedAction));
        expect(exception.provider, equals(provider));
      });
    });

    group('속성 검증', () {
      test('ExceptionInterface 구현이 올바르게 되어야 한다', () {
        // Given
        final exception = FakeExceptionGenerator.createOAuthAuthenticationFailed();

        // When & Then
        expect(exception.message, isA<String>());
        expect(exception.userMessage, isA<String>());
        expect(exception.title, isA<String>());
        expect(exception.errorType, isA<String>());
        expect(exception.errorCode, isA<String>());
        expect(exception.suggestedAction, isA<String>());
      });

      test('provider 속성이 올바르게 설정되어야 한다', () {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final exception = OAuthException.authenticationFailed(
          message: faker.lorem.sentence(),
          provider: provider,
        );

        // When & Then
        expect(exception.provider, equals(provider));
      });

      test('provider는 null일 수 있다', () {
        // Given
        final exception = OAuthException.authenticationFailed(
          message: faker.lorem.sentence(),
        );

        // When & Then
        expect(exception.provider, isNull);
      });

      test('모든 필수 속성이 null이 아니어야 한다', () {
        // Given
        final exception = FakeExceptionGenerator.createAuthenticationFailed();

        // When & Then
        expect(exception.message, isNotNull);
        expect(exception.userMessage, isNotNull);
        expect(exception.title, isNotNull);
        expect(exception.errorType, isNotNull);
        expect(exception.errorCode, isNotNull);
        expect(exception.suggestedAction, isNotNull);
      });

      test('다양한 OAuth 제공자로 생성할 수 있다', () {
        // Given
        final providers = ['google', 'apple', 'kakao'];
        final message = faker.lorem.sentence();

        // When & Then
        for (final provider in providers) {
          final exception = OAuthException.authenticationFailed(
            message: message,
            provider: provider,
          );
          expect(exception.provider, equals(provider));
        }
      });
    });

    group('toString', () {
      test('올바른 문자열 표현을 반환해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final exception = OAuthException.authenticationFailed(
          message: message,
          provider: provider,
        );

        // When
        final stringRepresentation = exception.toString();

        // Then
        expect(stringRepresentation, 'OAuthException(message: OAuth exception raised: $message, provider: $provider, errorCode: ${AuthErrorCodes.oauthAuthenticationFailed})');
      });

      test('provider가 null일 때도 올바른 문자열 표현을 반환해야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final exception = OAuthException.authenticationFailed(message: message);

        // When
        final stringRepresentation = exception.toString();

        // Then
        expect(stringRepresentation, 'OAuthException(message: OAuth exception raised: $message, provider: null, errorCode: ${AuthErrorCodes.oauthAuthenticationFailed})');
      });

      test('다른 메시지로 다른 문자열 표현을 반환해야 한다', () {
        // Given
        final message1 = faker.lorem.sentence();
        final message2 = faker.lorem.sentence();
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final exception1 = OAuthException.authenticationFailed(
          message: message1,
          provider: provider,
        );
        final exception2 = OAuthException.authenticationFailed(
          message: message2,
          provider: provider,
        );

        // When
        final string1 = exception1.toString();
        final string2 = exception2.toString();

        // Then
        expect(string1, isNot(equals(string2)));
        expect(string1, contains('OAuth exception raised: $message1'));
        expect(string2, contains('OAuth exception raised: $message2'));
      });
    });

    group('Factory 생성자별 특성', () {
      test('signOutFailed는 특별한 메시지 형식을 가져야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final exception = OAuthException.signOutFailed(message: message);

        // When & Then
        expect(exception.message, equals('OAuth sign out exception raised: $message'));
        expect(exception.errorType, equals(AuthErrorTypes.oauth));
        expect(exception.errorCode, equals(AuthErrorCodes.oauthSignOutFailed));
      });

      test('tokenRefreshFailed는 토큰 에러 타입을 가져야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final exception = OAuthException.tokenRefreshFailed(message: message);

        // When & Then
        expect(exception.errorType, equals(AuthErrorTypes.token));
        expect(exception.errorCode, equals(AuthErrorCodes.tokenRefreshFailed));
      });

      test('providerError는 제공자 에러 타입을 가져야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final exception = OAuthException.providerError(message: message);

        // When & Then
        expect(exception.errorType, equals(AuthErrorTypes.provider));
        expect(exception.errorCode, equals(AuthErrorCodes.oauthProviderError));
      });

      test('networkError는 네트워크 관련 메시지를 가져야 한다', () {
        // Given
        final message = faker.lorem.sentence();
        final exception = OAuthException.networkError(message: message);

        // When & Then
        expect(exception.message, equals('OAuth network error: $message'));
        expect(exception.userMessage, equals('네트워크 오류로 로그인할 수 없습니다.'));
        expect(exception.suggestedAction, equals('네트워크 연결을 확인하고 다시 시도해주세요.'));
      });
    });
  });
}
