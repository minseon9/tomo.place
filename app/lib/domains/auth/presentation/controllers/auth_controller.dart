import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/entities/social_provider.dart';
import '../../core/usecases/login_with_social_usecase.dart';
import '../../core/usecases/logout_usecase.dart';
import '../models/login_response.dart';

class AuthController extends Cubit<AuthState> {
  AuthController({
    required LoginWithSocialUseCase loginWithSocialUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginWithSocialUseCase = loginWithSocialUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthInitial());

  final LoginWithSocialUseCase _loginWithSocialUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> signupWithProvider(SocialProvider provider) async {
    await _performSocialAuth(
      authMethod: () => _loginWithSocialUseCase.execute(provider),
      provider: provider,
    );
  }

  Future<void> _performSocialAuth({
    required Future<LoginResponse?> Function() authMethod,
    required SocialProvider provider,
  }) async {
    try {
      emit(const AuthLoading());
      
      final loginResponse = await authMethod();
      
      // 사용자가 취소한 경우 (loginResponse가 null)
      if (loginResponse == null) {
        emit(const AuthInitial()); // Return to initial state
        return;
      }
      
      emit(AuthSuccess(loginResponse: loginResponse));
    } catch (e) {
      // Log the exception for debugging
      print('Auth error: $e');
      
      // For errors, emit failure state
      emit(AuthFailure(exception: e as Exception));
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      emit(const AuthLoading());
      
      await _logoutUseCase.execute();
      
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(exception: e as Exception));
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    if (state is AuthFailure) {
      emit(const AuthInitial());
    }
  }
}

/// 인증 상태 추상 클래스
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
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
  const AuthSuccess({required this.loginResponse});

  final LoginResponse loginResponse;

  @override
  List<Object> get props => [loginResponse];
}

/// 인증 실패 상태
class AuthFailure extends AuthState {
  const AuthFailure({required this.exception});

  final Exception exception;

  @override
  List<Object> get props => [exception];
}
