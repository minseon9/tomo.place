import 'package:flutter/material.dart';

import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../../../shared/design_system/tokens/typography.dart';
import '../../presentation/widgets/social_login_section.dart';
import '../../consts/social_label_variant.dart';

/// 회원가입 시작 화면 (Figma 노드 48:1264 대응)
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // 버튼 영역: 카카오/애플/구글/이메일
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SocialLoginSection(
                    includeEmail: true,
                    labelVariant: SocialLabelVariant.signup,
                  ),
                ],
              ),
            ),

            // 하단 안내문 및 하단 링크
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  Text(
                    '이미 계정이 있어요',
                    style: AppTypography.caption.copyWith(
                      color: DesignTokens.appColors['text_secondary'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Divider(color: DesignTokens.border),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '회원가입 시 개인정보 수집 • 이용 및 이용약관에 동의하는 것으로 간주합니다.',
                    style: AppTypography.caption.copyWith(
                      color: DesignTokens.appColors['text_secondary'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


