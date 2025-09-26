import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/unknown_exception.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExceptionNotifier', () {
    late ExceptionNotifier notifier;

    setUp(() {
      notifier = ExceptionNotifier();
    });

    test('ExceptionInterface를 report하면 상태에 그대로 반영된다', () {
      const exception = UnknownException(message: 'Test error');
      notifier.report(exception);
      expect(notifier.state, equals(exception));
    });

    test('일반 Exception을 report하면 UnknownException으로 변환된다', () {
      notifier.report('string error');
      expect(notifier.state, isA<UnknownException>());
      expect((notifier.state as UnknownException).message, 'string error');
    });

    test('clear를 호출하면 상태가 null이 된다', () {
      const exception = UnknownException(message: 'Test error');
      notifier.report(exception);
      notifier.clear();
      expect(notifier.state, isNull);
    });
  });
}
