import 'package:app/domains/auth/core/usecases/logout_usecase.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../utils/mock_factory/auth_mock_factory.dart';

void main() {
  group('LogoutUseCase', () {
    late MockAuthRepository mockAuthRepository;
    late MockAuthTokenRepository mockAuthTokenRepository;
    late LogoutUseCase useCase;

    setUp(() {
      mockAuthRepository = AuthMockFactory.createAuthRepository();
      mockAuthTokenRepository = AuthMockFactory.createAuthTokenRepository();
      useCase = LogoutUseCase(mockAuthRepository, mockAuthTokenRepository);
    });

    group('성공 케이스', () {
      test('정상적인 로그아웃이 성공해야 한다', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        when(() => mockAuthTokenRepository.clearToken()).thenAnswer((_) async {});

        // When
        await useCase.execute();

        // Then
        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });

      test('토큰이 올바르게 삭제되어야 한다', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        when(() => mockAuthTokenRepository.clearToken()).thenAnswer((_) async {});

        // When
        await useCase.execute();

        // Then
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });

    group('실패 케이스', () {
      test('네트워크 오류 시에도 토큰은 삭제되어야 한다', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenThrow(Exception('Network error'));
        when(() => mockAuthTokenRepository.clearToken()).thenAnswer((_) async {});

        // When & Then
        expect(
          () => useCase.execute(),
          throwsA(isA<Exception>()),
        );

        // 토큰은 finally 블록에서 삭제되어야 함
        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });

      test('저장소 오류 시에도 로그아웃은 시도되어야 한다', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        when(() => mockAuthTokenRepository.clearToken()).thenThrow(Exception('Storage error'));

        // When & Then
        try {
          await useCase.execute();
          fail('Exception should be thrown');
        } catch (e) {
          expect(e, isA<Exception>());
        }

        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });

      test('두 작업 모두 실패해도 예외가 전파되어야 한다', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenThrow(Exception('Network error'));
        when(() => mockAuthTokenRepository.clearToken()).thenThrow(Exception('Storage error'));

        // When & Then
        expect(
          () => useCase.execute(),
          throwsA(isA<Exception>()),
        );

        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });

    group('경계값 테스트', () {
      test('이미 로그아웃된 상태에서 로그아웃 시도', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        when(() => mockAuthTokenRepository.clearToken()).thenAnswer((_) async {});

        // When
        await useCase.execute();

        // Then
        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });

      test('빈 토큰으로 로그아웃 시도', () async {
        // Given
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        when(() => mockAuthTokenRepository.clearToken()).thenAnswer((_) async {});

        // When
        await useCase.execute();

        // Then
        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAuthTokenRepository.clearToken()).called(1);
      });
    });
  });
}