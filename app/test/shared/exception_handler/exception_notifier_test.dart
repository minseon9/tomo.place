import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/unknown_exception.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';

void main() {
  group('ExceptionNotifier', () {
    late ExceptionNotifier notifier;

    setUp(() {
      notifier = ExceptionNotifier();
    });

    group('초기 상태', () {
      test('초기 상태가 null이어야 한다', () {
        // When
        final initialState = notifier.state;

        // Then
        expect(initialState, isNull);
      });
    });

    group('report', () {
      test('ExceptionInterface를 report하면 상태에 그대로 반영된다', () {
        // When
        const exception = UnknownException(message: 'Test error');
        notifier.report(exception);

        // Then
        expect(notifier.state, equals(exception));
      });

      test('일반 Exception을 report하면 UnknownException으로 변환된다', () {
        // When
        notifier.report(Exception('test error'));

        // Then
        expect(notifier.state, isA<UnknownException>());
        expect((notifier.state as UnknownException).message, 'string error');
      });
    });

    group('clear', () {
      test('clear를 호출하면 상태가 null이 된다', () {
        const exception = UnknownException(message: 'Test error');
        notifier.report(exception);

        notifier.clear();

        expect(notifier.state, isNull);
      });

      test('이미 null인 상태에서 clear를 호출해도 문제없어야 한다', () {
        // Given
        expect(notifier.state, isNull);

        // When & Then
        expect(() => notifier.clear(), returnsNormally);
        expect(notifier.state, isNull);
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
        final notifier = ProviderContainer().read(exceptionNotifierProvider.notifier);

        // When & Then
        expect(notifier, isNotNull);
        expect(notifier, isA<ExceptionNotifier>());
      });

      test('Provider를 통해 state에 접근할 수 있어야 한다', () {
        // Given
        const exception = UnknownException(message: 'Test error');
        final providerContainer = ProviderContainer();

        final notifier = providerContainer.read(exceptionNotifierProvider.notifier);
        // When
        notifier.report(exception);

        // Then
        final state = providerContainer.read(exceptionNotifierProvider);
        expect(state, equals(exception));
      });
    });
  });
}
