import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/core/exceptions/error_codes.dart';
import 'package:tomo_place/domains/auth/core/exceptions/error_types.dart';
import 'package:tomo_place/domains/auth/core/exceptions/oauth_exception.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';

class _FakeException implements ExceptionInterface {
  @override
  final String message;

  const _FakeException(this.message);

  @override
  String get userMessage => message;

  @override
  String get title => 'title';

  @override
  String? get errorCode => 'code';

  @override
  String get errorType => 'type';

  @override
  String? get suggestedAction => 'action';
}

void main() {
  group('OAuthException', () {
    test('authenticationFailed 생성', () {
      final exception = OAuthException.authenticationFailed(
        message: 'fail',
        provider: 'google',
      );

      expect(exception.errorCode, AuthErrorCodes.oauthAuthenticationFailed);
      expect(exception.errorType, AuthErrorTypes.oauth);
      expect(exception.provider, 'google');
    });

    test('networkError 생성', () {
      final exception = OAuthException.networkError(
        message: 'network',
        provider: 'kakao',
      );

      expect(exception.errorCode, AuthErrorCodes.oauthNetworkError);
      expect(exception.provider, 'kakao');
    });

    test('기본 생성자', () {
      final exception = OAuthException(
        message: 'msg',
        userMessage: 'user',
        title: 'title',
        errorType: 'type',
        errorCode: 'code',
        suggestedAction: 'action',
        provider: 'apple',
      );

      expect(exception.message, 'msg');
      expect(exception.userMessage, 'user');
      expect(exception.provider, 'apple');
    });

    test('provider는 null 가능', () {
      final exception = OAuthException.authenticationFailed(message: 'fail');
      expect(exception.provider, isNull);
    });

    test('ExceptionInterface 구현', () {
      const fake = _FakeException('error');
      expect(fake.message, 'error');
      expect(fake.userMessage, 'error');
    });
  });
}
