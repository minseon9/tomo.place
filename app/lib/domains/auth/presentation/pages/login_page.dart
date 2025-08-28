import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../widgets/social_login_section.dart';
import '../widgets/login_bottom_links_group.dart';
import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../consts/social_label_variant.dart';

/// 로그인 화면
/// 
/// 피그마 디자인에 맞게 단순화된 로그인 화면입니다.
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

/// 로그인 페이지 콘텐츠
class _LoginPageContent extends StatelessWidget {
  const _LoginPageContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          SocialLoginSection(
            includeEmail: false,
            labelVariant: SocialLabelVariant.login,
            onKakaoPressed: () => context.read<AuthController>().loginWithKakao(),
            onApplePressed: () => context.read<AuthController>().loginWithApple(),
            onGooglePressed: () => context.read<AuthController>().loginWithGoogle(),
          ),
          const SizedBox(height: AppSpacing.xl),
          LoginBottomLinksGroup(
            onEmailLogin: () => context.push('/email-login'),
            onSignUp: () => context.push('/signup'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
