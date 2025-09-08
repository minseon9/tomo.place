import 'package:app/domains/auth/presentation/models/auth_state.dart';
import 'package:app/shared/exception_handler/models/exception_interface.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

void main() {
  group('AuthState', () {
    group('AuthInitial', () {
      test('const 생성자로 생성되어야 한다', () {
        // When
        const state = AuthInitial();

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthInitial>());
      });

      test('Equatable 구현이 올바르게 작동해야 한다', () {
        // Given
        const state1 = AuthInitial();
        const state2 = AuthInitial();

        // Then
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('props가 빈 리스트여야 한다', () {
        // Given
        const state = AuthInitial();

        // Then
        expect(state.props, isEmpty);
      });
    });

    group('AuthLoading', () {
      test('const 생성자로 생성되어야 한다', () {
        // When
        const state = AuthLoading();

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthLoading>());
      });

      test('Equatable 구현이 올바르게 작동해야 한다', () {
        // Given
        const state1 = AuthLoading();
        const state2 = AuthLoading();

        // Then
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('props가 빈 리스트여야 한다', () {
        // Given
        const state = AuthLoading();

        // Then
        expect(state.props, isEmpty);
      });
    });

    group('AuthSuccess', () {
      test('const 생성자로 생성되어야 한다', () {
        // Given
        const isNavigateHome = true;

        // When
        const state = AuthSuccess(isNavigateHome);

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthSuccess>());
        expect(state.isNavigateHome, equals(isNavigateHome));
      });

      test('isNavigateHome 속성이 올바르게 설정되어야 한다', () {
        // Given
        const isNavigateHomeTrue = true;
        const isNavigateHomeFalse = false;

        // When
        const stateTrue = AuthSuccess(isNavigateHomeTrue);
        const stateFalse = AuthSuccess(isNavigateHomeFalse);

        // Then
        expect(stateTrue.isNavigateHome, isTrue);
        expect(stateFalse.isNavigateHome, isFalse);
      });

      test('Equatable 구현이 올바르게 작동해야 한다', () {
        // Given
        const isNavigateHome = true;
        const state1 = AuthSuccess(isNavigateHome);
        const state2 = AuthSuccess(isNavigateHome);

        // Then
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('다른 isNavigateHome 값으로 생성된 상태는 달라야 한다', () {
        // Given
        const stateTrue = AuthSuccess(true);
        const stateFalse = AuthSuccess(false);

        // Then
        expect(stateTrue, isNot(equals(stateFalse)));
        expect(stateTrue.hashCode, isNot(equals(stateFalse.hashCode)));
      });

      test('props에 isNavigateHome이 포함되어야 한다', () {
        // Given
        const isNavigateHome = true;
        const state = AuthSuccess(isNavigateHome);

        // Then
        expect(state.props, equals([isNavigateHome]));
      });
    });

    group('AuthFailure', () {
      test('const 생성자로 생성되어야 한다', () {
        // When
        const state = AuthFailure(error: _MockExceptionInterface());

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthFailure>());
        expect(state.error, isA<ExceptionInterface>());
      });

      test('error 속성이 올바르게 설정되어야 한다', () {
        // Given
        final errorMessage = faker.lorem.sentence();
        final error = _MockExceptionInterface(message: errorMessage);

        // When
        final state = AuthFailure(error: error);

        // Then
        expect(state.error, isA<ExceptionInterface>());
      });

      test('Equatable 구현이 올바르게 작동해야 한다', () {
        // Given
        const error = _MockExceptionInterface();
        const state1 = AuthFailure(error: error);
        const state2 = AuthFailure(error: error);

        // Then
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('다른 error로 생성된 상태는 달라야 한다', () {
        // Given
        const error1 = _MockExceptionInterface(message: 'Error 1');
        const error2 = _MockExceptionInterface(message: 'Error 2');
        const state1 = AuthFailure(error: error1);
        const state2 = AuthFailure(error: error2);

        // Then
        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });

      test('props에 error가 포함되어야 한다', () {
        // Given
        const error = _MockExceptionInterface();
        const state = AuthFailure(error: error);

        // Then
        expect(state.props, equals([error]));
      });
    });

    group('상태 비교', () {
      test('서로 다른 상태는 같지 않아야 한다', () {
        // Given
        const initial = AuthInitial();
        const loading = AuthLoading();
        const success = AuthSuccess(true);
        const failure = AuthFailure(error: _MockExceptionInterface());

        // Then
        expect(initial, isNot(equals(loading)));
        expect(loading, isNot(equals(success)));
        expect(success, isNot(equals(failure)));
        expect(failure, isNot(equals(initial)));
      });

      test('동일한 상태는 같아야 한다', () {
        // Given
        const initial1 = AuthInitial();
        const initial2 = AuthInitial();
        const loading1 = AuthLoading();
        const loading2 = AuthLoading();
        const success1 = AuthSuccess(true);
        const success2 = AuthSuccess(true);
        const failure1 = AuthFailure(error: _MockExceptionInterface());
        const failure2 = AuthFailure(error: _MockExceptionInterface());

        // Then
        expect(initial1, equals(initial2));
        expect(loading1, equals(loading2));
        expect(success1, equals(success2));
        expect(failure1, equals(failure2));
      });

      test('AuthSuccess의 다른 isNavigateHome 값은 다른 상태여야 한다', () {
        // Given
        const successTrue = AuthSuccess(true);
        const successFalse = AuthSuccess(false);

        // Then
        expect(successTrue, isNot(equals(successFalse)));
      });
    });
  });
}

/// 테스트용 Mock ExceptionInterface 구현
class _MockExceptionInterface implements ExceptionInterface {
  final String message;

  const _MockExceptionInterface({this.message = 'Mock error'});

  @override
  String get userMessage => 'Mock user message';

  @override
  String get title => 'Mock title';

  @override
  String? get errorCode => 'MOCK_ERROR';

  @override
  String get errorType => 'MockError';

  @override
  String? get suggestedAction => 'Mock action';

  @override
  List<Object?> get props => [message];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MockExceptionInterface &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
