import 'package:flutter_bloc/flutter_bloc.dart';

import '../../consts/social_provider.dart';
import '../../core/entities/auth_token.dart';
import '../../core/usecases/logout_usecase.dart';
import '../../core/usecases/signup_with_social_usecase.dart';

// FIXME:  AuthState 분리
class AuthController extends Cubit<AuthState> {
  AuthController({
    required SignupWithSocialUseCase loginWithSocialUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _signupWithSocialUseCase = loginWithSocialUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthInitial());

  final SignupWithSocialUseCase _signupWithSocialUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> signupWithProvider(SocialProvider provider) async {
    await _performSocialAuth(
      authMethod: () => _signupWithSocialUseCase.execute(provider),
      provider: provider,
    );
  }

  Future<void> _performSocialAuth({
    required Future<AuthToken?> Function() authMethod,
    required SocialProvider provider,
  }) async {
    try {
      emit(const AuthLoading());

      final authToken = await authMethod();

      if (authToken == null) {
        emit(const AuthInitial());
        return;
      }

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(exception: e as Exception));
    }
  }

  Future<void> logout() async {
    try {
      emit(const AuthLoading());

      await _logoutUseCase.execute();

      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(exception: e as Exception));
    }
  }

  void clearError() {
    if (state is AuthFailure) {
      emit(const AuthInitial());
    }
  }
}

abstract class AuthState {
  const AuthState();
}

/// 초기 상태
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// 로딩 상태
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// 인증 성공 상태
class AuthSuccess extends AuthState {
  const AuthSuccess();
}

/// 인증 실패 상태
class AuthFailure extends AuthState {
  const AuthFailure({required this.exception});

  final Exception exception;
}
