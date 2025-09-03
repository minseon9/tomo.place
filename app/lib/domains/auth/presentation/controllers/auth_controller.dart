import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/exceptions/error_interface.dart';
import '../../../../shared/exceptions/generic_exception.dart';
import '../../consts/social_provider.dart';
import '../../core/entities/auth_token.dart';
import '../../core/usecases/logout_usecase.dart';
import '../../core/usecases/signup_with_social_usecase.dart';
import '../models/auth_state.dart';

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
      final error = _convertToErrorInterface(e);
      emit(AuthFailure(error: error));
    }
  }

  Future<void> logout() async {
    try {
      emit(const AuthLoading());

      await _logoutUseCase.execute();

      emit(const AuthInitial());
    } catch (e) {
      final error = _convertToErrorInterface(e);
      emit(AuthFailure(error: error));
    }
  }

  void clearError() {
    if (state is AuthFailure) {
      emit(const AuthInitial());
    }
  }

  ErrorInterface _convertToErrorInterface(dynamic exception) {
    if (exception is ErrorInterface) {
      return exception;
    }

    return GenericException.fromException(exception);
  }
}
