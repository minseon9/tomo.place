import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/authenticate_with_social.dart';
import '../../../social_login/domain/usecases/kakao_login.dart';
import '../../../social_login/domain/usecases/google_login.dart';
import '../../../social_login/domain/usecases/apple_login.dart';

/// 인증 상태 관리를 위한 Cubit
/// 
/// UI와 비즈니스 로직을 연결하는 Presentation Layer의 컨트롤러입니다.
/// 순수한 상태 관리만 담당하며, 비즈니스 로직은 UseCase에 위임합니다.
class AuthController extends Cubit<AuthState> {
  AuthController({
    required KakaoLoginUseCase kakaoLoginUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required AppleLoginUseCase appleLoginUseCase,
    required AuthenticateWithSocialUseCase authenticateUseCase,
  }) : _kakaoLoginUseCase = kakaoLoginUseCase,
       _googleLoginUseCase = googleLoginUseCase,
       _appleLoginUseCase = appleLoginUseCase,
       _authenticateUseCase = authenticateUseCase,
       super(const AuthInitial());

  final KakaoLoginUseCase _kakaoLoginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final AppleLoginUseCase _appleLoginUseCase;
  final AuthenticateWithSocialUseCase _authenticateUseCase;

  /// 카카오 로그인 실행
  Future<void> loginWithKakao() async {
    await _performSocialLogin(
      socialLoginUseCase: _kakaoLoginUseCase,
      provider: 'Kakao',
    );
  }

  /// 구글 로그인 실행
  Future<void> loginWithGoogle() async {
    await _performSocialLogin(
      socialLoginUseCase: _googleLoginUseCase,
      provider: 'Google',
    );
  }

  /// 애플 로그인 실행
  Future<void> loginWithApple() async {
    await _performSocialLogin(
      socialLoginUseCase: _appleLoginUseCase,
      provider: 'Apple',
    );
  }

  /// 소셜 로그인 공통 로직
  Future<void> _performSocialLogin({
    required Future<dynamic> Function() socialLoginUseCase,
    required String provider,
  }) async {
    try {
      emit(const AuthLoading());
      
      // 1단계: 소셜 로그인으로 계정 정보 획득
      final socialAccount = await socialLoginUseCase();
      
      // 2단계: 소셜 계정 정보로 서버 인증
      final user = await _authenticateUseCase(socialAccount);
      
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(
        message: '$provider 로그인에 실패했습니다: ${e.toString()}',
        provider: provider.toLowerCase(),
      ));
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

  /// 로그아웃
  Future<void> logout() async {
    try {
      emit(const AuthLoading());
      
      // TODO: 로그아웃 UseCase 구현 후 연결
      await Future.delayed(const Duration(milliseconds: 500));
      
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
