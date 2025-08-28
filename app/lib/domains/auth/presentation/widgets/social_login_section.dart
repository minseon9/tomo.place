import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import 'social_login_button.dart';
import '../../consts/social_provider.dart';
import '../../consts/social_label_variant.dart';
import '../../../../shared/design_system/tokens/spacing.dart';

/// 소셜 로그인 버튼들을 모아놓은 섹션
/// 
/// 소셜 로그인 버튼들을 배치하고 AuthController와 연결하는 역할을 합니다.
/// UI 구성과 상태 관리의 연결점 역할을 담당합니다.
class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({
    super.key,
    this.includeEmail = false,
    this.labelVariant = SocialLabelVariant.login,
  });

  final bool includeEmail;
  final SocialLabelVariant labelVariant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 카카오 로그인 버튼 (Primary)
          BlocBuilder<AuthController, AuthState>(
            builder: (context, state) {
              return SocialLoginButton(
                provider: SocialProvider.kakao,
                labelVariant: labelVariant,
                onPressed: () => context.read<AuthController>().loginWithKakao(),
                isLoading: state is AuthLoading,
              );
            },
          ),
          
          // 애플 로그인 버튼
          BlocBuilder<AuthController, AuthState>(
            builder: (context, state) {
              return SocialLoginButton(
                provider: SocialProvider.apple,
                labelVariant: labelVariant,
                onPressed: () => context.read<AuthController>().loginWithApple(),
                isLoading: state is AuthLoading,
              );
            },
          ),
          
          // 구글 로그인 버튼
          BlocBuilder<AuthController, AuthState>(
            builder: (context, state) {
              return SocialLoginButton(
                provider: SocialProvider.google,
                labelVariant: labelVariant,
                onPressed: () => context.read<AuthController>().loginWithGoogle(),
                isLoading: state is AuthLoading,
              );
            },
          ),
          
          if (includeEmail)
            SocialLoginButton(
              provider: SocialProvider.email,
              labelVariant: labelVariant,
              onPressed: () {
                context.push('/email-login');
              },
            ),
        ],
      ),
    );
  }
}
