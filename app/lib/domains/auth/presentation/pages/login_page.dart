import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../widgets/social_login_section.dart';
import '../../consts/social_label_variant.dart';
import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../../../shared/design_system/tokens/typography.dart';
// SocialLoginButton은 도메인 위젯으로 이동됨

/// 로그인 화면
/// 
/// 순수한 UI 컴포넌트로서 비즈니스 로직에 의존하지 않습니다.
/// 상태 변화에 따른 UI 업데이트와 사용자 입력 처리만 담당합니다.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: BlocConsumer<AuthController, AuthState>(
          listener: (context, state) {
            _handleStateChange(context, state);
          },
          builder: (context, state) {
            return const _LoginPageContent();
          },
        ),
      ),
    );
  }

  /// 상태 변화에 따른 UI 처리
  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      // 로그인 성공 시 홈 화면으로 이동
      context.go('/home');
    } else if (state is AuthFailure) {
      // 로그인 실패 시 에러 메시지 표시
      _showErrorSnackBar(context, state.message);
    }
  }

  /// 에러 메시지 스낵바 표시
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.appColors['error'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () => context.read<AuthController>().clearError(),
        ),
      ),
    );
  }
}

/// 로그인 페이지 콘텐츠
class _LoginPageContent extends StatelessWidget {
  const _LoginPageContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 로고 및 타이틀 영역
        const Expanded(
          flex: 2,
          child: _LogoSection(),
        ),
        
        // 소셜 로그인 버튼 영역
        Expanded(
          flex: 3,
          child: const SocialLoginSection(
            includeEmail: false,
            labelVariant: SocialLabelVariant.login,
          ),
        ),
        
        // 하단 링크 영역
        const _BottomLinksSection(),
      ],
    );
  }
}

/// 로고 섹션
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: 실제 로고 이미지로 교체
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignTokens.tomoPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.place,
              size: 40,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '토모플레이스',
            style: AppTypography.h1.copyWith(
              color: DesignTokens.appColors['text_primary'],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '당신만의 특별한 장소를 찾아보세요',
            style: AppTypography.bodyMedium.copyWith(
              color: DesignTokens.appColors['text_secondary'],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 하단 링크 섹션
class _BottomLinksSection extends StatelessWidget {
  const _BottomLinksSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          // 약관 동의 텍스트
          Text(
            '회원가입 시 개인정보 수집 • 이용 및 이용약관에\n동의하는 것으로 간주됩니다.',
            style: AppTypography.bodySmall.copyWith(
              color: DesignTokens.appColors['text_secondary'],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // 이메일 로그인 / 회원가입 링크
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  context.push('/email-login');
                },
                child: Text(
                  '이메일로 로그인',
                  style: AppTypography.bodyMedium.copyWith(
                    color: DesignTokens.appColors['text_primary'],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' | ',
                style: AppTypography.bodyMedium.copyWith(
                  color: DesignTokens.appColors['text_secondary'],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 회원가입 페이지로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원가입 페이지는 준비 중입니다.')),
                  );
                },
                child: Text(
                  '회원 가입',
                  style: AppTypography.bodyMedium.copyWith(
                    color: DesignTokens.appColors['text_primary'],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
