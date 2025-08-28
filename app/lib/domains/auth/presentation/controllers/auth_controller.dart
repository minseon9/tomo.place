import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../services/auth_service.dart';

/// 인증 상태 관리를 위한 Cubit
/// 
/// UI와 비즈니스 로직을 연결하는 Presentation Layer의 컨트롤러입니다.
/// 개선된 아키텍처에 따라 Service Layer를 사용합니다.
class AuthController extends Cubit<AuthState> {
  AuthController({
    required AuthService authService,
  }) : _authService = authService,
       super(const AuthInitial());

  final AuthService _authService;

  /// 구글 로그인 실행
  Future<void> loginWithGoogle() async {
    await _performSocialAuth(
      authMethod: () => _authService.loginWithGoogle(),
      provider: 'Google',
    );
  }

  /// 구글 회원가입 실행
  Future<void> signupWithGoogle() async {
    await _performSocialAuth(
      authMethod: () => _authService.signupWithGoogle(),
      provider: 'Google',
    );
  }

  /// 카카오 로그인 실행 (준비 중)
  Future<void> loginWithKakao() async {
    emit(const AuthFailure(
      message: '카카오 로그인은 아직 지원하지 않습니다.',
      provider: 'kakao',
    ));
  }

  /// 카카오 회원가입 실행 (준비 중)
  Future<void> signupWithKakao() async {
    emit(const AuthFailure(
      message: '카카오 회원가입은 아직 지원하지 않습니다.',
      provider: 'kakao',
    ));
  }

  /// 애플 로그인 실행 (준비 중)
  Future<void> loginWithApple() async {
    emit(const AuthFailure(
      message: '애플 로그인은 아직 지원하지 않습니다.',
      provider: 'apple',
    ));
  }

  /// 애플 회원가입 실행 (준비 중)
  Future<void> signupWithApple() async {
    emit(const AuthFailure(
      message: '애플 회원가입은 아직 지원하지 않습니다.',
      provider: 'apple',
    ));
  }

  /// 소셜 인증 공통 로직
  Future<void> _performSocialAuth({
    required Future<User> Function() authMethod,
    required String provider,
  }) async {
    try {
      emit(const AuthLoading());
      
      final user = await authMethod();
      
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(
        message: '$provider 인증에 실패했습니다: ${e.toString()}',
        provider: provider.toLowerCase(),
      ));
      
      // TODO: 팝업 메시지 표시 로직 추가
    }
  }

  /// 이메일 로그인 (추후 구현)
  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());
    
    // TODO: 이메일 로그인 UseCase 구현 후 연결
    await Future.delayed(const Duration(seconds: 1));
    
    emit(const AuthFailure(
      message: '이메일 로그인은 아직 구현되지 않았습니다.',
      provider: 'email',
    ));
  }

  /// 이메일 회원가입 (추후 구현)
  Future<void> signupWithEmail(String email, String password) async {
    emit(const AuthLoading());
    
    // TODO: 이메일 회원가입 UseCase 구현 후 연결
    await Future.delayed(const Duration(seconds: 1));
    
    emit(const AuthFailure(
      message: '이메일 회원가입은 아직 구현되지 않았습니다.',
      provider: 'email',
    ));
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
  const AuthSuccess({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
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
