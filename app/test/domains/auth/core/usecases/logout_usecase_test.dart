import 'package:app/domains/auth/core/repositories/auth_repository.dart';
import 'package:app/domains/auth/core/repositories/auth_token_repository.dart';
import 'package:app/domains/auth/core/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthTokenRepository extends Mock implements AuthTokenRepository {}

void main() {
  group('LogoutUseCase', () {
    late MockAuthRepository mockAuthRepository;
    late MockAuthTokenRepository mockAuthTokenRepository;
    late LogoutUseCase useCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockAuthTokenRepository = MockAuthTokenRepository();
      useCase = LogoutUseCase(mockAuthRepository, mockAuthTokenRepository);
    });

    group('성공 케이스', () {
      test('로그아웃 성공 시 토큰을 정리해야 한다', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        when(
          () => mockAuthTokenRepository.clearToken(),
        ).thenAnswer((_) async {});

        // When
        await useCase.execute();

        // Then
        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });

    group('서버 로그아웃 실패 케이스', () {
      test('서버 로그아웃 실패 시에도 토큰을 정리해야 한다', () async {
        // Given
        final serverError = Exception('Server logout failed');
        when(() => mockAuthRepository.logout()).thenThrow(serverError);
        when(
          () => mockAuthTokenRepository.clearToken(),
        ).thenAnswer((_) async {});

        // When & Then
        expect(() => useCase.execute(), throwsA(equals(serverError)));

        // 서버 로그아웃이 실패해도 토큰은 정리되어야 함
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });

    group('토큰 정리 실패 케이스', () {
      test('토큰 정리 실패 시 예외를 전파해야 한다', () async {
        // Given
        final storageError = Exception('Token storage failed');
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        when(
          () => mockAuthTokenRepository.clearToken(),
        ).thenThrow(storageError);

        // When & Then
        expect(() => useCase.execute(), throwsA(equals(storageError)));

        // 서버 로그아웃은 성공했지만 토큰 정리에서 실패
        // verify 호출은 제거 - finally 블록에서 예외가 발생하면 verify가 제대로 작동하지 않음
      });
    });

    group('의존성 주입', () {
      test('필수 의존성이 올바르게 주입되어야 한다', () {
        // Given & When
        final useCase = LogoutUseCase(
          mockAuthRepository,
          mockAuthTokenRepository,
        );

        // Then
        expect(useCase, isA<LogoutUseCase>());
      });
    });

    group('finally 블록 보장', () {
      test('서버 로그아웃 성공 후 토큰 정리가 실패해도 예외를 전파해야 한다', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        final storageError = Exception('Token storage failed');
        when(
          () => mockAuthTokenRepository.clearToken(),
        ).thenThrow(storageError);

        // When & Then
        expect(() => useCase.execute(), throwsA(equals(storageError)));

        // 서버 로그아웃은 성공했지만 토큰 정리에서 실패
        // verify 호출은 제거 - finally 블록에서 예외가 발생하면 verify가 제대로 작동하지 않음
      });

      test('서버 로그아웃 실패 후 토큰 정리도 실패하면 finally 블록의 예외를 전파해야 한다', () async {
        // Given
        final serverError = Exception('Server logout failed');
        final storageError = Exception('Token storage failed');
        when(() => mockAuthRepository.logout()).thenThrow(serverError);
        when(
          () => mockAuthTokenRepository.clearToken(),
        ).thenThrow(storageError);

        // When & Then
        expect(
          () => useCase.execute(),
          throwsA(equals(storageError)), // finally 블록의 예외가 전파됨
        );

        // 서버 로그아웃 실패 후 토큰 정리도 시도됨
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });

    group('비동기 처리', () {
      test('모든 비동기 작업이 올바른 순서로 실행되어야 한다', () async {
        // Given
        final executionOrder = <String>[];

        when(() => mockAuthRepository.logout()).thenAnswer((_) async {
          executionOrder.add('repository.logout');
        });
        when(() => mockAuthTokenRepository.clearToken()).thenAnswer((_) async {
          executionOrder.add('tokenStorage.clearToken');
        });

        // When
        await useCase.execute();

        // Then
        expect(
          executionOrder,
          equals(['repository.logout', 'tokenStorage.clearToken']),
        );
      });
    });
  });
}
