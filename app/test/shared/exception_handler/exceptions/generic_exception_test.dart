import 'package:flutter_test/flutter_test.dart';

import 'package:app/shared/exception_handler/exceptions/generic_exception.dart';

void main() {
  group('GenericException', () {
    group('constructor', () {
      test('should create instance with all required parameters', () {
        const exception = GenericException(
          message: 'Test error message',
          userMessage: '사용자 오류 메시지',
          title: '오류 제목',
          errorType: 'TestType',
          errorCode: 'TEST_001',
          suggestedAction: '테스트 액션',
          originalException: 'Original error',
        );

        expect(exception.message, equals('Test error message'));
        expect(exception.userMessage, equals('사용자 오류 메시지'));
        expect(exception.title, equals('오류 제목'));
        expect(exception.errorType, equals('TestType'));
        expect(exception.errorCode, equals('TEST_001'));
        expect(exception.suggestedAction, equals('테스트 액션'));
        expect(exception.originalException, equals('Original error'));
      });

      test('should create instance with optional parameters', () {
        const exception = GenericException(
          message: 'Test error message',
          userMessage: '사용자 오류 메시지',
          title: '오류 제목',
          errorType: 'TestType',
        );

        expect(exception.message, equals('Test error message'));
        expect(exception.userMessage, equals('사용자 오류 메시지'));
        expect(exception.title, equals('오류 제목'));
        expect(exception.errorType, equals('TestType'));
        expect(exception.errorCode, isNull);
        expect(exception.suggestedAction, isNull);
        expect(exception.originalException, isNull);
      });
    });

    group('fromException', () {
      test('should convert Exception to GenericException', () {
        final originalException = Exception('Test exception');
        final genericException = GenericException.fromException(originalException);

        expect(genericException.message, equals('Exception: Test exception'));
        expect(genericException.userMessage, equals('예상치 못한 오류가 발생했습니다.'));
        expect(genericException.title, equals('오류'));
        expect(genericException.errorType, equals('Generic'));
        expect(genericException.errorCode, equals('GEN_001'));
        expect(genericException.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        expect(genericException.originalException, equals(originalException));
      });

      test('should convert Error to GenericException', () {
        final originalError = ArgumentError('Test error');
        final genericException = GenericException.fromException(originalError);

        expect(genericException.message, equals('Invalid argument(s): Test error'));
        expect(genericException.userMessage, equals('예상치 못한 오류가 발생했습니다.'));
        expect(genericException.title, equals('오류'));
        expect(genericException.errorType, equals('Generic'));
        expect(genericException.errorCode, equals('GEN_001'));
        expect(genericException.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        expect(genericException.originalException, equals(originalError));
      });

      test('should handle null exception', () {
        final genericException = GenericException.fromException(null);

        expect(genericException.message, equals('Unknown error'));
        expect(genericException.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(genericException.title, equals('오류'));
        expect(genericException.errorType, equals('Generic'));
        expect(genericException.errorCode, equals('GEN_001'));
        expect(genericException.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        expect(genericException.originalException, isNull);
      });

      test('should handle unknown exception type', () {
        final unknownObject = 'String error';
        final genericException = GenericException.fromException(unknownObject);

        expect(genericException.message, equals('String error'));
        expect(genericException.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(genericException.title, equals('오류'));
        expect(genericException.errorType, equals('Generic'));
        expect(genericException.errorCode, equals('GEN_001'));
        expect(genericException.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        expect(genericException.originalException, equals(unknownObject));
      });
    });

    group('fromNetworkException', () {
      test('should create network exception with correct properties', () {
        final originalException = Exception('Network error');
        final genericException = GenericException.fromNetworkException(originalException);

        expect(genericException.message, equals('Exception: Network error'));
        expect(genericException.userMessage, equals('네트워크 오류가 발생했습니다.'));
        expect(genericException.title, equals('네트워크 오류'));
        expect(genericException.errorType, equals('Network'));
        expect(genericException.errorCode, equals('GEN_002'));
        expect(genericException.suggestedAction, equals('네트워크 연결을 확인하고 다시 시도해주세요.'));
        expect(genericException.originalException, equals(originalException));
      });

      test('should preserve original exception', () {
        final originalException = 'Custom network error';
        final genericException = GenericException.fromNetworkException(originalException);

        expect(genericException.originalException, equals(originalException));
      });
    });

    group('fromServerException', () {
      test('should create server exception with correct properties', () {
        final originalException = Exception('Server error');
        final genericException = GenericException.fromServerException(originalException);

        expect(genericException.message, equals('Exception: Server error'));
        expect(genericException.userMessage, equals('서버 오류가 발생했습니다.'));
        expect(genericException.title, equals('서버 오류'));
        expect(genericException.errorType, equals('Server'));
        expect(genericException.errorCode, equals('GEN_003'));
        expect(genericException.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        expect(genericException.originalException, equals(originalException));
      });

      test('should preserve original exception', () {
        final originalException = 'Custom server error';
        final genericException = GenericException.fromServerException(originalException);

        expect(genericException.originalException, equals(originalException));
      });
    });

    group('fromAuthException', () {
      test('should create auth exception with correct properties', () {
        final originalException = Exception('Auth error');
        final genericException = GenericException.fromAuthException(originalException);

        expect(genericException.message, equals('Exception: Auth error'));
        expect(genericException.userMessage, equals('인증 오류가 발생했습니다.'));
        expect(genericException.title, equals('인증 오류'));
        expect(genericException.errorType, equals('Authentication'));
        expect(genericException.errorCode, equals('GEN_004'));
        expect(genericException.suggestedAction, equals('다시 로그인해주세요.'));
        expect(genericException.originalException, equals(originalException));
      });

      test('should preserve original exception', () {
        final originalException = 'Custom auth error';
        final genericException = GenericException.fromAuthException(originalException);

        expect(genericException.originalException, equals(originalException));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
        );

        final result = exception.toString();
        expect(result, contains('GenericException'));
        expect(result, contains('Test error'));
        expect(result, contains('null')); // originalException is null
      });

      test('should include original exception in string', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
          originalException: 'Original error',
        );

        final result = exception.toString();
        expect(result, contains('GenericException'));
        expect(result, contains('Test error'));
        expect(result, contains('Original error'));
      });
    });

    group('ExceptionInterface implementation', () {
      test('should implement all required properties', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
        );

        expect(exception.message, isA<String>());
        expect(exception.userMessage, isA<String>());
        expect(exception.title, isA<String>());
        expect(exception.errorType, isA<String>());
        expect(exception.errorCode, isA<String?>());
        expect(exception.suggestedAction, isA<String?>());
      });

      test('should return correct message', () {
        const exception = GenericException(
          message: 'Test error message',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
        );

        expect(exception.message, equals('Test error message'));
      });

      test('should return correct userMessage', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류 메시지',
          title: '오류',
          errorType: 'Test',
        );

        expect(exception.userMessage, equals('사용자 오류 메시지'));
      });

      test('should return correct title', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류',
          title: '오류 제목',
          errorType: 'Test',
        );

        expect(exception.title, equals('오류 제목'));
      });

      test('should return correct errorCode', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
          errorCode: 'TEST_001',
        );

        expect(exception.errorCode, equals('TEST_001'));
      });

      test('should return correct errorType', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'TestType',
        );

        expect(exception.errorType, equals('TestType'));
      });

      test('should return correct suggestedAction', () {
        const exception = GenericException(
          message: 'Test error',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
          suggestedAction: '테스트 액션',
        );

        expect(exception.suggestedAction, equals('테스트 액션'));
      });
    });

    group('edge cases', () {
      test('should handle empty string message', () {
        const exception = GenericException(
          message: '',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
        );

        expect(exception.message, equals(''));
      });

      test('should handle special characters in message', () {
        const exception = GenericException(
          message: 'Error with special chars: !@#\$%^&*()',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
        );

        expect(exception.message, equals('Error with special chars: !@#\$%^&*()'));
      });

      test('should handle unicode characters', () {
        const exception = GenericException(
          message: '오류 메시지 with unicode: 🚀',
          userMessage: '사용자 오류',
          title: '오류',
          errorType: 'Test',
        );

        expect(exception.message, equals('오류 메시지 with unicode: 🚀'));
      });
    });
  });
}
