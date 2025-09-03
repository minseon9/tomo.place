import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/exceptions/error_interface.dart';
import '../../../../shared/exceptions/generic_exception.dart';
import '../../../../shared/services/error_reporter.dart';
import '../../consts/social_provider.dart';
import '../../core/entities/auth_token.dart';
import '../../core/usecases/logout_usecase.dart';
import '../../core/usecases/signup_with_social_usecase.dart';
import '../models/auth_state.dart';

class AuthController extends Cubit<AuthState> {
  AuthController({
    required SignupWithSocialUseCase loginWithSocialUseCase,
    required LogoutUseCase logoutUseCase,
    required ErrorReporter errorReporter,
  }) : _signupWithSocialUseCase = loginWithSocialUseCase,
       _logoutUseCase = logoutUseCase,
       _errorReporter = errorReporter,
       super(const AuthInitial());

  final SignupWithSocialUseCase _signupWithSocialUseCase;
  final LogoutUseCase _logoutUseCase;
  final ErrorReporter _errorReporter;

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
      _errorReporter.report(error);
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
      _errorReporter.report(error);
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
