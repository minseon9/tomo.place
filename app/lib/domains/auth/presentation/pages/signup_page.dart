import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../widgets/social_login_section.dart';
import '../widgets/signup_bottom_links_group.dart';
import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../consts/social_label_variant.dart';

/// 회원가입 화면
/// 
/// 피그마 디자인에 맞게 단순화된 회원가입 화면입니다.
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
            return const _SignupPageContent();
          },
        ),
      ),
    );
  }

  /// 상태 변화에 따른 UI 처리
  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      // 회원가입 성공 시 홈 화면으로 이동
      context.go('/home');
    } else if (state is AuthFailure) {
      // 회원가입 실패 시 에러 메시지 표시
      _showErrorSnackBar(context, state.message);
    }
  }

  /// 에러 메시지 스낵바 표시
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.error,
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

/// 회원가입 페이지 콘텐츠
class _SignupPageContent extends StatelessWidget {
  const _SignupPageContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          // 좌우 중앙 정렬을 위한 Center 위젯
          Center(
            child: SocialLoginSection(
              includeEmail: true,
              labelVariant: SocialLabelVariant.signup,
              onKakaoPressed: () => context.read<AuthController>().signupWithKakao(),
              onApplePressed: () => context.read<AuthController>().signupWithApple(),
              onGooglePressed: () => context.read<AuthController>().signupWithGoogle(),
              onEmailPressed: () => context.push('/email-signup'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // 좌우 중앙 정렬을 위한 Center 위젯
          Center(
            child: SignupBottomLinksGroup(
              onEmailLogin: () => context.go('/login'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}


