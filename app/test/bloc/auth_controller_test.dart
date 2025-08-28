import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/domains/auth/presentation/controllers/auth_controller.dart';
import 'package:app/domains/auth/services/auth_service.dart';
import 'package:app/domains/auth/domain/entities/user.dart';
import 'package:app/shared/exceptions/auth_exception.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('AuthController Tests', () {
    late MockAuthService mockAuthService;
    late AuthController authController;

    setUp(() {
      mockAuthService = MockAuthService();
      authController = AuthController(authService: mockAuthService);
    });

    tearDown(() {
      authController.close();
    });

    test('initial state should be AuthInitial', () {
      expect(authController.state, isA<AuthInitial>());
    });

    group('loginWithGoogle', () {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      blocTest<AuthController, AuthState>(
        'should emit [AuthLoading, AuthSuccess] when login succeeds',
        build: () {
          when(mockAuthService.loginWithGoogle()).thenAnswer((_) async => testUser);
          return authController;
        },
        act: (controller) => controller.loginWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ],
        verify: (_) {
          verify(mockAuthService.loginWithGoogle()).called(1);
        },
      );

      blocTest<AuthController, AuthState>(
        'should emit [AuthLoading, AuthFailure] when login fails',
        build: () {
          when(mockAuthService.loginWithGoogle())
              .thenThrow(AuthException('Login failed'));
          return authController;
        },
        act: (controller) => controller.loginWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
        verify: (_) {
          verify(mockAuthService.loginWithGoogle()).called(1);
        },
      );

      blocTest<AuthController, AuthState>(
        'should emit [AuthLoading, AuthFailure] when network error occurs',
        build: () {
          when(mockAuthService.loginWithGoogle())
              .thenThrow(Exception('Network error'));
          return authController;
        },
        act: (controller) => controller.loginWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
        verify: (_) {
          verify(mockAuthService.loginWithGoogle()).called(1);
        },
      );
    });

    group('signupWithGoogle', () {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      blocTest<AuthController, AuthState>(
        'should emit [AuthLoading, AuthSuccess] when signup succeeds',
        build: () {
          when(mockAuthService.signupWithGoogle()).thenAnswer((_) async => testUser);
          return authController;
        },
        act: (controller) => controller.signupWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ],
        verify: (_) {
          verify(mockAuthService.signupWithGoogle()).called(1);
        },
      );

      blocTest<AuthController, AuthState>(
        'should emit [AuthLoading, AuthFailure] when signup fails',
        build: () {
          when(mockAuthService.signupWithGoogle())
              .thenThrow(AuthException('Signup failed'));
          return authController;
        },
        act: (controller) => controller.signupWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
        verify: (_) {
          verify(mockAuthService.signupWithGoogle()).called(1);
        },
      );
    });

    group('logout', () {
      blocTest<AuthController, AuthState>(
        'should emit [AuthLoading, AuthInitial] when logout succeeds',
        build: () {
          when(mockAuthService.logout()).thenAnswer((_) async {});
          return authController;
        },
        act: (controller) => controller.logout(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthInitial>(),
        ],
        verify: (_) {
          verify(mockAuthService.logout()).called(1);
        },
      );

      blocTest<AuthController, AuthState>(
        'should emit [AuthLoading, AuthFailure] when logout fails',
        build: () {
          when(mockAuthService.logout())
              .thenThrow(AuthException('Logout failed'));
          return authController;
        },
        act: (controller) => controller.logout(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
        verify: (_) {
          verify(mockAuthService.logout()).called(1);
        },
      );
    });

    group('AuthState Tests', () {
      test('AuthInitial should be equal to other AuthInitial', () {
        expect(const AuthInitial(), equals(const AuthInitial()));
      });

      test('AuthLoading should be equal to other AuthLoading', () {
        expect(const AuthLoading(), equals(const AuthLoading()));
      });

      test('AuthSuccess should be equal when users are equal', () {
        const user1 = User(
          id: '1', 
          email: 'test@example.com', 
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );
        const user2 = User(
          id: '1', 
          email: 'test@example.com', 
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );
        
        expect(const AuthSuccess(user: user1), equals(const AuthSuccess(user: user2)));
      });

      test('AuthSuccess should not be equal when users are different', () {
        const user1 = User(
          id: '1', 
          email: 'test@example.com', 
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );
        const user2 = User(
          id: '2', 
          email: 'test@example.com', 
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );
        
        expect(const AuthSuccess(user: user1), isNot(equals(const AuthSuccess(user: user2))));
      });

      test('AuthFailure should be equal when messages are equal', () {
        expect(const AuthFailure(message: 'Error'), equals(const AuthFailure(message: 'Error')));
      });

      test('AuthFailure should not be equal when messages are different', () {
        expect(const AuthFailure(message: 'Error 1'), isNot(equals(const AuthFailure(message: 'Error 2'))));
      });

      test('AuthInitial should not equal AuthLoading', () {
        expect(const AuthInitial(), isNot(equals(const AuthLoading())));
      });

      test('AuthLoading should not equal AuthSuccess', () {
        const user = User(
          id: '1', 
          email: 'test@example.com', 
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );
        expect(const AuthLoading(), isNot(equals(const AuthSuccess(user: user))));
      });

      test('AuthSuccess should not equal AuthFailure', () {
        const user = User(
          id: '1', 
          email: 'test@example.com', 
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );
        expect(const AuthSuccess(user: user), isNot(equals(const AuthFailure(message: 'Error'))));
      });
    });

    group('Error Handling', () {
      blocTest<AuthController, AuthState>(
        'should handle AuthException with specific message',
        build: () {
          when(mockAuthService.loginWithGoogle())
              .thenThrow(const AuthException('Invalid credentials', code: 'AUTH_001'));
          return authController;
        },
        act: (controller) => controller.loginWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          predicate<AuthFailure>((state) => 
            state.message == 'Invalid credentials'),
        ],
      );

      blocTest<AuthController, AuthState>(
        'should handle generic Exception',
        build: () {
          when(mockAuthService.loginWithGoogle())
              .thenThrow(Exception('Unexpected error'));
          return authController;
        },
        act: (controller) => controller.loginWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          predicate<AuthFailure>((state) => 
            state.message.contains('Unexpected error')),
        ],
      );

      blocTest<AuthController, AuthState>(
        'should handle null Exception message',
        build: () {
          when(mockAuthService.loginWithGoogle())
              .thenThrow(Exception());
          return authController;
        },
        act: (controller) => controller.loginWithGoogle(),
        expect: () => [
          isA<AuthLoading>(),
          predicate<AuthFailure>((state) => 
            state.message.isNotEmpty),
        ],
      );
    });
  });
}
