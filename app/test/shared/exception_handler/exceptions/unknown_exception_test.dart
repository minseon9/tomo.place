import 'package:flutter_test/flutter_test.dart';

import 'package:app/shared/exception_handler/exceptions/unknown_exception.dart';

void main() {
  group('UnknownException', () {
    group('constructor', () {
      test('should create instance with required message', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.message, equals('Test unknown error'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(exception.title, equals('오류'));
        expect(exception.errorCode, isNull);
        expect(exception.errorType, equals('unknown'));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
      });

      test('should use default values for optional parameters', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.message, equals('Test unknown error'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(exception.title, equals('오류'));
        expect(exception.errorCode, isNull);
        expect(exception.errorType, equals('unknown'));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
      });

      test('should allow custom values for optional parameters', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          userMessage: '사용자 정의 오류 메시지',
          title: '사용자 정의 제목',
          errorCode: 'UNK_001',
          errorType: 'CustomType',
          suggestedAction: '사용자 정의 액션',
        );

        expect(exception.message, equals('Test unknown error'));
        expect(exception.userMessage, equals('사용자 정의 오류 메시지'));
        expect(exception.title, equals('사용자 정의 제목'));
        expect(exception.errorCode, equals('UNK_001'));
        expect(exception.errorType, equals('CustomType'));
        expect(exception.suggestedAction, equals('사용자 정의 액션'));
      });
    });

    group('ExceptionInterface implementation', () {
      test('should implement all required properties', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.message, isA<String>());
        expect(exception.userMessage, isA<String>());
        expect(exception.title, isA<String>());
        expect(exception.errorType, isA<String>());
        expect(exception.errorCode, isA<String?>());
        expect(exception.suggestedAction, isA<String?>());
      });

      test('should return correct message', () {
        const exception = UnknownException(message: 'Test unknown error message');

        expect(exception.message, equals('Test unknown error message'));
      });

      test('should return default userMessage', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
      });

      test('should return default title', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.title, equals('오류'));
      });

      test('should return default errorCode', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.errorCode, isNull);
      });

      test('should return default errorType', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.errorType, equals('unknown'));
      });

      test('should return default suggestedAction', () {
        const exception = UnknownException(message: 'Test unknown error');

        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
      });
    });

    group('custom values', () {
      test('should use custom userMessage when provided', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          userMessage: '사용자 정의 오류 메시지',
        );

        expect(exception.userMessage, equals('사용자 정의 오류 메시지'));
        expect(exception.title, equals('오류')); // default value
        expect(exception.errorType, equals('unknown')); // default value
      });

      test('should use custom title when provided', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          title: '사용자 정의 제목',
        );

        expect(exception.title, equals('사용자 정의 제목'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.')); // default value
        expect(exception.errorType, equals('unknown')); // default value
      });

      test('should use custom errorCode when provided', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          errorCode: 'UNK_001',
        );

        expect(exception.errorCode, equals('UNK_001'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.')); // default value
        expect(exception.title, equals('오류')); // default value
      });

      test('should use custom errorType when provided', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          errorType: 'CustomType',
        );

        expect(exception.errorType, equals('CustomType'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.')); // default value
        expect(exception.title, equals('오류')); // default value
      });

      test('should use custom suggestedAction when provided', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          suggestedAction: '사용자 정의 액션',
        );

        expect(exception.suggestedAction, equals('사용자 정의 액션'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.')); // default value
        expect(exception.title, equals('오류')); // default value
      });
    });

    group('edge cases', () {
      test('should handle empty message', () {
        const exception = UnknownException(message: '');

        expect(exception.message, equals(''));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(exception.title, equals('오류'));
        expect(exception.errorType, equals('unknown'));
      });

      test('should handle special characters in message', () {
        const exception = UnknownException(
          message: 'Error with special chars: !@#\$%^&*()',
        );

        expect(exception.message, equals('Error with special chars: !@#\$%^&*()'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(exception.title, equals('오류'));
        expect(exception.errorType, equals('unknown'));
      });

      test('should handle unicode characters', () {
        const exception = UnknownException(
          message: '오류 메시지 with unicode: 🚀',
        );

        expect(exception.message, equals('오류 메시지 with unicode: 🚀'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(exception.title, equals('오류'));
        expect(exception.errorType, equals('unknown'));
      });

      test('should handle very long message', () {
        final longMessage = 'A' * 1000; // 1000 character message
        final exception = UnknownException(message: longMessage);

        expect(exception.message, equals(longMessage));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
        expect(exception.title, equals('오류'));
        expect(exception.errorType, equals('unknown'));
      });

      test('should handle null errorCode', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          errorCode: null,
        );

        expect(exception.errorCode, isNull);
        expect(exception.message, equals('Test unknown error'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
      });

      test('should handle null suggestedAction', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          suggestedAction: null,
        );

        expect(exception.suggestedAction, isNull);
        expect(exception.message, equals('Test unknown error'));
        expect(exception.userMessage, equals('알 수 없는 오류가 발생했습니다.'));
      });
    });

    group('immutability', () {
      test('should be immutable after creation', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          userMessage: '사용자 정의 오류 메시지',
          title: '사용자 정의 제목',
          errorCode: 'UNK_001',
          errorType: 'CustomType',
          suggestedAction: '사용자 정의 액션',
        );

        // 모든 속성이 final이므로 변경할 수 없어야 함
        expect(exception.message, equals('Test unknown error'));
        expect(exception.userMessage, equals('사용자 정의 오류 메시지'));
        expect(exception.title, equals('사용자 정의 제목'));
        expect(exception.errorCode, equals('UNK_001'));
        expect(exception.errorType, equals('CustomType'));
        expect(exception.suggestedAction, equals('사용자 정의 액션'));
      });
    });

    group('const constructor', () {
      test('should support const constructor', () {
        const exception1 = UnknownException(message: 'Test unknown error');
        const exception2 = UnknownException(message: 'Test unknown error');

        // const 생성자로 생성된 객체는 동일한 인스턴스여야 함
        expect(identical(exception1, exception2), isTrue);
      });

      test('should support const constructor with all parameters', () {
        const exception = UnknownException(
          message: 'Test unknown error',
          userMessage: '사용자 정의 오류 메시지',
          title: '사용자 정의 제목',
          errorCode: 'UNK_001',
          errorType: 'CustomType',
          suggestedAction: '사용자 정의 액션',
        );

        expect(exception.message, equals('Test unknown error'));
        expect(exception.userMessage, equals('사용자 정의 오류 메시지'));
        expect(exception.title, equals('사용자 정의 제목'));
        expect(exception.errorCode, equals('UNK_001'));
        expect(exception.errorType, equals('CustomType'));
        expect(exception.suggestedAction, equals('사용자 정의 액션'));
      });
    });
  });
}
