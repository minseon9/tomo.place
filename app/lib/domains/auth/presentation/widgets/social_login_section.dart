import 'package:flutter/material.dart';

import '../../../../shared/design_system/tokens/spacing.dart';
import '../../consts/social_label_variant.dart';
import '../../core/entities/social_provider.dart';
import 'social_login_button.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({
    super.key,
    this.labelVariant = SocialLabelVariant.signup,
    this.onProviderPressed,
  });

  final SocialLabelVariant labelVariant;
  final void Function(SocialProvider provider)? onProviderPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kakao 로그인 (비활성화)
        SocialLoginButton(
          provider: SocialProvider.kakao,
          onPressed: null, // 비활성화
          labelVariant: labelVariant,
        ),
        const SizedBox(height: AppSpacing.md),
        // Apple 로그인 (비활성화)
        SocialLoginButton(
          provider: SocialProvider.apple,
          onPressed: null, // 비활성화
          labelVariant: labelVariant,
        ),
        const SizedBox(height: AppSpacing.md),
        // Google 로그인 (활성화)
        SocialLoginButton(
          provider: SocialProvider.google,
          onPressed: onProviderPressed != null 
              ? () => onProviderPressed!(SocialProvider.google)
              : null,
          labelVariant: labelVariant,
        ),
      ],
    );
  }
}
