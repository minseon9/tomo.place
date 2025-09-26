import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';

void main() {
  group('AuthState', () {
    test('AuthInitial은 value object 동등성을 가진다', () {
      const a = AuthInitial();
      const b = AuthInitial();

      expect(a, equals(b));
      expect(a.props, isEmpty);
    });

    test('AuthLoading은 value object 동등성을 가진다', () {
      const a = AuthLoading();
      const b = AuthLoading();

      expect(a, equals(b));
      expect(a.props, isEmpty);
    });

    test('AuthSuccess는 isNavigateHome을 props로 가진다', () {
      const state = AuthSuccess(true);
      expect(state.isNavigateHome, isTrue);
      expect(state.props, [true]);
    });

    test('AuthFailure는 error를 props로 가진다', () {
      final error = _FakeException();
      final state = AuthFailure(error: error);

      expect(state.error, error);
      expect(state.props, [error]);
    });

    test('서로 다른 상태는 같지 않다', () {
      const initial = AuthInitial();
      const loading = AuthLoading();
      const success = AuthSuccess(true);
      final failure = AuthFailure(error: _FakeException());

      expect(initial, isNot(loading));
      expect(loading, isNot(success));
      expect(success, isNot(failure));
    });
  });
}

class _FakeException implements ExceptionInterface {
  @override
  final String message;

  _FakeException({this.message = 'fake'});

  @override
  String get userMessage => message;

  @override
  String get title => 'title';

  @override
  String? get errorCode => null;

  @override
  String get errorType => 'Fake';

  @override
  String? get suggestedAction => null;
}
