import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/exception_handler/exception_notifier.dart';
import '../../../../shared/exception_handler/exceptions/unknown_exception.dart';
import '../../../../shared/exception_handler/models/exception_interface.dart';
import '../../consts/social_provider.dart';
import '../../core/entities/auth_token.dart';
import '../../core/entities/authentication_result.dart';
import '../../core/usecases/logout_usecase.dart';
import '../../core/usecases/refresh_token_usecase.dart';
import '../../core/usecases/signup_with_social_usecase.dart';
import '../../core/usecases/usecase_providers.dart';
import '../models/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthInitial());

  final Ref _ref;

  SignupWithSocialUseCase get _signup =>
      _ref.read(signupWithSocialUseCaseProvider);

  LogoutUseCase get _logout => _ref.read(logoutUseCaseProvider);

  RefreshTokenUseCase get _refresh => _ref.read(refreshTokenUseCaseProvider);

  ExceptionNotifier get _effects => _ref.read(exceptionNotifierProvider.notifier);

  Future<void> signupWithProvider(SocialProvider provider) async {
    state = const AuthLoading();
    try {
      final AuthToken? token = await _signup.execute(provider);
      if (token == null) {
        state = const AuthInitial();
        return;
      }
      state = const AuthSuccess(true);
    } catch (e) {
      final err = _toError(e);
      state = AuthFailure(error: err);
      _effects.report(err);
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _logout.execute();
      state = const AuthInitial();
    } catch (e) {
      final err = _toError(e);
      state = AuthFailure(error: err);
      _effects.report(err);
    }
  }

  Future<AuthenticationResult?> refreshToken(bool isLogin) async {
    state = const AuthLoading();
    try {
      final AuthenticationResult result = await _refresh.execute();
      if (!result.isAuthenticated()) {
        state = const AuthInitial();
      } else {
        state = AuthSuccess(isLogin);
      }

      return result;
    } catch (e) {
      final err = _toError(e);
      state = AuthFailure(error: err);
      _effects.report(err);

      return null;
    }
  }

  ExceptionInterface _toError(dynamic e) {
    if (e is ExceptionInterface) {
      return e;
    } else {
      return UnknownException(message: e.toString());
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref);
});
