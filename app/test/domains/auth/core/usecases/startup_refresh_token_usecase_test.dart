import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:app/domains/auth/core/repositories/auth_repository.dart';
import 'package:app/domains/auth/core/repositories/auth_token_repository.dart';
import 'package:app/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAuthTokenRepository extends Mock implements AuthTokenRepository {}

void main() {
  group('StartupRefreshTokenUseCase', () {
    late _MockAuthRepository authRepository;
    late _MockAuthTokenRepository tokenRepository;
    late RefreshTokenUseCase useCase;

    setUp(() {
      authRepository = _MockAuthRepository();
      tokenRepository = _MockAuthTokenRepository();
      useCase = RefreshTokenUseCase(authRepository, tokenRepository);
    });

    test('returns unauthenticated when no current token', () async {
      when(
        () => tokenRepository.getCurrentToken(),
      ).thenAnswer((_) async => null);

      final result = await useCase.execute();
      expect(result.status, AuthenticationStatus.unauthenticated);
    });

    test('returns authenticated when refresh token is valid', () async {
      final token = AuthToken(
        accessToken: 'a',
        refreshToken: 'r',
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 1)),
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );
      when(
        () => tokenRepository.getCurrentToken(),
      ).thenAnswer((_) async => token);

      final result = await useCase.execute();
      expect(result.status, AuthenticationStatus.authenticated);
      expect(result.token, isNotNull);
    });

    test(
      'refreshes token when refresh token expired and saves new token',
      () async {
        final expired = AuthToken(
          accessToken: 'old',
          refreshToken: 'old_r',
          accessTokenExpiresAt: DateTime.now().subtract(
            const Duration(minutes: 1),
          ),
          refreshTokenExpiresAt: DateTime.now().subtract(
            const Duration(minutes: 1),
          ),
        );
        final renewed = AuthToken(
          accessToken: 'new',
          refreshToken: 'new_r',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 30)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );

        when(
          () => tokenRepository.getCurrentToken(),
        ).thenAnswer((_) async => expired);
        when(
          () => authRepository.refreshToken('old_r'),
        ).thenAnswer((_) async => renewed);
        when(() => tokenRepository.saveToken(renewed)).thenAnswer((_) async {});

        final result = await useCase.execute();
        expect(result.status, AuthenticationStatus.authenticated);
        verify(() => tokenRepository.saveToken(renewed)).called(1);
      },
    );

    test('clears token and returns unauthenticated on error', () async {
      final expired = AuthToken(
        accessToken: 'old',
        refreshToken: 'old_r',
        accessTokenExpiresAt: DateTime.now().subtract(
          const Duration(minutes: 1),
        ),
        refreshTokenExpiresAt: DateTime.now().subtract(
          const Duration(minutes: 1),
        ),
      );
      when(
        () => tokenRepository.getCurrentToken(),
      ).thenAnswer((_) async => expired);
      when(
        () => authRepository.refreshToken(any()),
      ).thenThrow(Exception('fail'));
      when(() => tokenRepository.clearToken()).thenAnswer((_) async {});

      final result = await useCase.execute();
      expect(result.status, AuthenticationStatus.unauthenticated);
      verify(() => tokenRepository.clearToken()).called(1);
    });
  });
}
