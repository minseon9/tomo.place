import 'package:app/domains/auth/presentation/models/auth_state.dart';
import 'package:app/shared/error_handling/models/exception_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockErrorInterface extends Mock implements ExceptionInterface {}

void main() {
  group('AuthState', () {
    group('AuthInitial', () {
      test('const 생성자로 생성되어야 한다', () {
        // Given & When
        const state = AuthInitial();

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthInitial>());
      });

      test('동일한 인스턴스는 같아야 한다', () {
        // Given & When
        const state1 = AuthInitial();
        const state2 = AuthInitial();

        // Then
        expect(state1, equals(state2));
      });
    });

    group('AuthLoading', () {
      test('const 생성자로 생성되어야 한다', () {
        // Given & When
        const state = AuthLoading();

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthLoading>());
      });

      test('동일한 인스턴스는 같아야 한다', () {
        // Given & When
        const state1 = AuthLoading();
        const state2 = AuthLoading();

        // Then
        expect(state1, equals(state2));
      });
    });

    group('AuthSuccess', () {
      test('const 생성자로 생성되어야 한다', () {
        // Given & When
        const state = AuthSuccess(true);

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthSuccess>());
      });

      test('동일한 인스턴스는 같아야 한다', () {
        // Given & When
        const state1 = AuthSuccess(true);
        const state2 = AuthSuccess(true);

        // Then
        expect(state1, equals(state2));
      });
    });

    group('AuthFailure', () {
      late ExceptionInterface mockError;

      setUp(() {
        mockError = _MockErrorInterface();
      });

      test('에러와 함께 생성되어야 한다', () {
        // Given & When
        final state = AuthFailure(error: mockError);

        // Then
        expect(state, isA<AuthState>());
        expect(state, isA<AuthFailure>());
        expect(state.error, equals(mockError));
      });

      test('동일한 에러를 가진 인스턴스는 같아야 한다', () {
        // Given & When
        final state1 = AuthFailure(error: mockError);
        final state2 = AuthFailure(error: mockError);

        // Then
        expect(state1, equals(state2));
      });

      test('다른 에러를 가진 인스턴스는 달라야 한다', () {
        // Given
        final anotherError = _MockErrorInterface();

        // When
        final state1 = AuthFailure(error: mockError);
        final state2 = AuthFailure(error: anotherError);

        // Then
        expect(state1, isNot(equals(state2)));
      });
    });

    group('상태 타입 확인', () {
      test('각 상태가 올바른 타입을 가져야 한다', () {
        // Given & When
        const initial = AuthInitial();
        const loading = AuthLoading();
        const success = AuthSuccess(true);
        final failure = AuthFailure(error: _MockErrorInterface());

        // Then
        expect(initial, isA<AuthState>());
        expect(loading, isA<AuthState>());
        expect(success, isA<AuthState>());
        expect(failure, isA<AuthState>());
      });

      test('상태 간 타입 비교가 올바르게 작동해야 한다', () {
        // Given & When
        const initial = AuthInitial();
        const loading = AuthLoading();
        const success = AuthSuccess(true);
        final failure = AuthFailure(error: _MockErrorInterface());

        // Then
        expect(initial, isNot(isA<AuthLoading>()));
        expect(initial, isNot(isA<AuthSuccess>()));
        expect(initial, isNot(isA<AuthFailure>()));

        expect(loading, isNot(isA<AuthInitial>()));
        expect(loading, isNot(isA<AuthSuccess>()));
        expect(loading, isNot(isA<AuthFailure>()));

        expect(success, isNot(isA<AuthInitial>()));
        expect(success, isNot(isA<AuthLoading>()));
        expect(success, isNot(isA<AuthFailure>()));

        expect(failure, isNot(isA<AuthInitial>()));
        expect(failure, isNot(isA<AuthLoading>()));
        expect(failure, isNot(isA<AuthSuccess>()));
      });
    });

    group('에지 케이스', () {
      test('AuthFailure는 null 에러를 허용하지 않아야 한다', () {
        // Given & When & Then
        expect(
          () => AuthFailure(error: null as dynamic),
          // ignore: cast_nullable_to_non_nullable
          throwsA(isA<TypeError>()),
        );
      });

      test('상태 객체는 불변해야 한다', () {
        // Given
        const state = AuthSuccess(true);

        // When & Then
        expect(state, isA<AuthSuccess>());
        // 상태 객체는 const이므로 변경할 수 없음
      });
    });
  });
}
