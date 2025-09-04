import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/repositories/auth_token_repository.dart';
import 'package:app/domains/auth/core/usecases/check_auth_status_usecase.dart';

class _MockAuthTokenRepository extends Mock implements AuthTokenRepository {}

void main() {
  group('CheckAuthStatusUseCase', () {
    late _MockAuthTokenRepository tokenRepository;
    late CheckAuthStatusUseCase useCase;

    setUp(() {
      tokenRepository = _MockAuthTokenRepository();
      useCase = CheckAuthStatusUseCase(authTokenRepository: tokenRepository);
    });

    test('returns true when access token is about to expire but not expired (current logic)', () async {
      final token = AuthToken(
        accessToken: 'a',
        refreshToken: 'r',
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 1)),
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      when(() => tokenRepository.getCurrentToken()).thenAnswer((_) async => token);

      final result = await useCase.execute();
      expect(result, isTrue);
    });

    test('returns false when no token', () async {
      when(() => tokenRepository.getCurrentToken()).thenAnswer((_) async => null);

      final result = await useCase.execute();
      expect(result, isFalse);
    });

    test('returns false when repository throws', () async {
      when(() => tokenRepository.getCurrentToken()).thenThrow(Exception('db error'));

      final result = await useCase.execute();
      expect(result, isFalse);
    });
  });
}


