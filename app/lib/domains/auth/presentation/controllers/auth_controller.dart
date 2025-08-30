import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/login_response.dart';
import '../../services/auth_service.dart';
import '../../consts/social_provider.dart';

class AuthController extends Cubit<AuthState> {
  AuthController({
    required AuthService authService,
  }) : _authService = authService,
       super(const AuthInitial());

  final AuthService _authService;

  Future<void> signupWithProvider(SocialProvider provider) async {
    await _performSocialAuth(
      authMethod: () => _authService.signupWithProvider(provider),
      provider: provider,
    );
  }

  Future<void> _performSocialAuth({
    required Future<LoginResponse> Function() authMethod,
    required SocialProvider provider,
  }) async {
    try {
      emit(const AuthLoading());
      
      final loginResponse = await authMethod();
      
      emit(AuthSuccess(loginResponse: loginResponse));
    } catch (e) {
      emit(AuthFailure(
        message: '${provider.code} 인증에 실패했습니다: ${e.toString()}',
        provider: provider.code,
      ));
      
      // TODO: 팝업 메시지 표시 로직 추가
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      emit(const AuthLoading());
      
      await _authService.logout();
      
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(
        message: '로그아웃에 실패했습니다: ${e.toString()}',
      ));
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
  const AuthFailure({
    required this.message,
    this.provider,
    this.code,
  });

  final String message;
  final String? provider;
  final String? code;

  @override
  List<Object?> get props => [message, provider, code];
}
