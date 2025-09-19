import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/auth_token_repository_impl.dart';
import 'logout_usecase.dart';
import 'refresh_token_usecase.dart';
import 'signup_with_social_usecase.dart';

final signupWithSocialUseCaseProvider = Provider<SignupWithSocialUseCase>(
  (ref) => SignupWithSocialUseCase(
    ref.read(authRepositoryProvider),
    ref.read(authTokenRepositoryProvider),
    ref.container,
  ),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(
    ref.read(authRepositoryProvider),
    ref.read(authTokenRepositoryProvider),
  ),
);

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>(
  (ref) => RefreshTokenUseCase(
    ref.read(authRepositoryProvider),
    ref.read(authTokenRepositoryProvider),
  ),
);
