import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/generic_exception.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/network_exception.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/server_exception.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/unknown_exception.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExceptionNotifier', () {
    late ProviderContainer container;
    late ExceptionNotifier exceptionNotifier;

    setUp(() {
      container = ProviderContainer();
      exceptionNotifier = container.read(exceptionNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('초기 상태', () {
      test('초기 상태가 null이어야 한다', () {
        // When
        final initialState = container.read(exceptionNotifierProvider);

        // Then
        expect(initialState, isNull);
      });
    });

    group('report', () {
      test('UnknownException을 보고할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(message: 'Test unknown error');

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(exception));
        expect(currentState, isA<UnknownException>());
        expect(currentState?.message, equals('Test unknown error'));
      });

      test('NetworkException을 보고할 수 있어야 한다', () {
        // Given
        final exception = NetworkException.connectionTimeout();

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(exception));
        expect(currentState, isA<NetworkException>());
        expect(currentState?.message, equals('Connection timeout occurred'));
        expect(currentState?.userMessage,
            equals('네트워크 연결 시간이 초과되었습니다. 다시 시도해주세요.'));
      });

      test('ServerException을 보고할 수 있어야 한다', () {
        // Given
        final exception = ServerException.internalServerError(
            message: 'Database connection failed');

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(exception));
        expect(currentState, isA<ServerException>());
        expect(currentState?.message,
            equals('Internal server error: Database connection failed'));
        expect(currentState?.userMessage,
            equals('서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
      });

      test('GenericException을 보고할 수 있어야 한다', () {
        // Given
        const exception = GenericException(
          message: 'Test generic error',
          userMessage: '일반적인 오류가 발생했습니다.',
          title: '오류',
          errorType: 'Generic',
        );

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(exception));
        expect(currentState, isA<GenericException>());
        expect(currentState?.message, equals('Test generic error'));
        expect(currentState?.userMessage, equals('일반적인 오류가 발생했습니다.'));
      });

      test('여러 번의 report 호출 시 마지막 예외가 상태가 되어야 한다', () {
        // Given
        const firstException = UnknownException(message: 'First error');
        final secondException = NetworkException.noConnection();
        final thirdException = ServerException.badRequest(
            message: 'Bad request');

        // When
        exceptionNotifier.report(firstException);
        expect(
            container.read(exceptionNotifierProvider), equals(firstException));

        exceptionNotifier.report(secondException);
        expect(
            container.read(exceptionNotifierProvider), equals(secondException));

        exceptionNotifier.report(thirdException);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(thirdException));
        expect(currentState, isA<ServerException>());
        expect(currentState?.message, equals('Bad request: Bad request'));
      });
    });

    group('clear', () {
      test('상태를 null로 초기화할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(message: 'Test error');
        exceptionNotifier.report(exception);
        expect(container.read(exceptionNotifierProvider), isNotNull);

        // When
        exceptionNotifier.clear();

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, isNull);
      });

      test('이미 null인 상태에서 clear를 호출해도 문제없어야 한다', () {
        // Given
        expect(container.read(exceptionNotifierProvider), isNull);

        // When & Then
        expect(() => exceptionNotifier.clear(), returnsNormally);
        expect(container.read(exceptionNotifierProvider), isNull);
      });

      test('report 후 clear 후 다시 report가 가능해야 한다', () {
        // Given
        const firstException = UnknownException(message: 'First error');
        final secondException = NetworkException.connectionError();

        // When
        exceptionNotifier.report(firstException);
        expect(
            container.read(exceptionNotifierProvider), equals(firstException));

        exceptionNotifier.clear();
        expect(container.read(exceptionNotifierProvider), isNull);

        exceptionNotifier.report(secondException);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(secondException));
        expect(currentState, isA<NetworkException>());
      });
    });

    group('상태 변화 검증', () {
      test('상태 변화가 올바르게 반영되어야 한다', () {
        // Given
        const exception = UnknownException(message: 'Test error');

        // When & Then
        // 초기 상태
        expect(container.read(exceptionNotifierProvider), isNull);

        // report 후
        exceptionNotifier.report(exception);
        expect(container.read(exceptionNotifierProvider), equals(exception));

        // clear 후
        exceptionNotifier.clear();
        expect(container.read(exceptionNotifierProvider), isNull);
      });

      test('여러 컨테이너에서 독립적으로 동작해야 한다', () {
        // Given
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();
        final notifier1 = container1.read(exceptionNotifierProvider.notifier);
        final notifier2 = container2.read(exceptionNotifierProvider.notifier);

        const exception1 = UnknownException(message: 'Error 1');
        const exception2 = UnknownException(message: 'Error 2');

        // When
        notifier1.report(exception1);
        notifier2.report(exception2);

        // Then
        expect(container1.read(exceptionNotifierProvider), equals(exception1));
        expect(container2.read(exceptionNotifierProvider), equals(exception2));

        // Cleanup
        container1.dispose();
        container2.dispose();
      });
    });

    group('ExceptionInterface 구현체들', () {
      test('모든 ExceptionInterface 구현체를 처리할 수 있어야 한다', () {
        // Given
        final exceptions = <ExceptionInterface>[
          const UnknownException(message: 'Unknown error'),
          NetworkException.connectionTimeout(),
          NetworkException.noConnection(),
          NetworkException.dnsResolutionFailed(),
          NetworkException.sslCertificateError(),
          NetworkException.requestCancelled(),
          NetworkException.badResponse(),
          NetworkException.connectionError(),
          NetworkException.securityConnectionFailed(),
          ServerException.badRequest(message: 'Bad request'),
          ServerException.unauthorized(message: 'Unauthorized'),
          ServerException.forbidden(message: 'Forbidden'),
          ServerException.notFound(message: 'Not found'),
          ServerException.internalServerError(message: 'Internal error'),
          ServerException.badGateway(message: 'Bad gateway'),
          ServerException.serviceUnavailable(message: 'Service unavailable'),
          const GenericException(
            message: 'Generic error',
            userMessage: '일반 오류',
            title: '오류',
            errorType: 'Generic',
          ),
        ];

        // When & Then
        for (int i = 0; i < exceptions.length; i++) {
          final exception = exceptions[i];
          exceptionNotifier.report(exception);

          final currentState = container.read(exceptionNotifierProvider);
          expect(currentState, equals(exception),
              reason: 'Exception at index $i should be reported correctly');
        }
      });

      test('ExceptionInterface의 모든 속성을 올바르게 접근할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(
          message: 'Test error message',
          userMessage: '테스트 오류 메시지',
          title: '테스트 오류',
          errorCode: 'TEST_001',
          errorType: 'TestType',
          suggestedAction: '테스트 액션',
        );

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, isNotNull);
        expect(currentState?.message, equals('Test error message'));
        expect(currentState?.userMessage, equals('테스트 오류 메시지'));
        expect(currentState?.title, equals('테스트 오류'));
        expect(currentState?.errorCode, equals('TEST_001'));
        expect(currentState?.errorType, equals('TestType'));
        expect(currentState?.suggestedAction, equals('테스트 액션'));
      });
    });

    group('Provider 동작 검증', () {
      test('Provider가 올바르게 생성되어야 한다', () {
        // Given & When
        final provider = exceptionNotifierProvider;

        // Then
        expect(provider, isNotNull);
        expect(provider, isA<
            StateNotifierProvider<ExceptionNotifier, ExceptionInterface?>>());
      });

      test('Provider를 통해 notifier에 접근할 수 있어야 한다', () {
        // Given
        final notifier = container.read(exceptionNotifierProvider.notifier);

        // When & Then
        expect(notifier, isNotNull);
        expect(notifier, isA<ExceptionNotifier>());
        expect(notifier, same(exceptionNotifier));
      });

      test('Provider를 통해 state에 접근할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(message: 'Test error');

        // When
        exceptionNotifier.report(exception);

        // Then
        final state = container.read(exceptionNotifierProvider);
        expect(state, equals(exception));
      });
    });

    group('에지 케이스', () {
      test('null 예외를 report할 수 없어야 한다', () {
        // Given
        ExceptionInterface? nullException;

        // When & Then
        expect(() => exceptionNotifier.report(nullException!),
            throwsA(isA<TypeError>()));
      });

      test('빈 메시지를 가진 예외도 처리할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(message: '');

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(exception));
        expect(currentState?.message, equals(''));
      });

      test('특수 문자가 포함된 메시지도 처리할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(
            message: 'Error with special chars: !@#\$%^&*()');

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(exception));
        expect(currentState?.message,
            equals('Error with special chars: !@#\$%^&*()'));
      });

      test('유니코드 문자가 포함된 메시지도 처리할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(message: '오류 메시지 with unicode: 🚀');

        // When
        exceptionNotifier.report(exception);

        // Then
        final currentState = container.read(exceptionNotifierProvider);
        expect(currentState, equals(exception));
        expect(currentState?.message, equals('오류 메시지 with unicode: 🚀'));
      });
    });
  });
}
