import 'package:flutter/material.dart';

import '../../../../shared/ui/design_system/tokens/spacing.dart';
import '../../consts/social_provider.dart';
import 'social_login_button.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key, this.onProviderPressed});

  final void Function(SocialProvider provider)? onProviderPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialLoginButton(
          provider: SocialProvider.kakao,
          onPressed: null, // 비활성화
        ),
        const SizedBox(height: AppSpacing.md),
        SocialLoginButton(
          provider: SocialProvider.apple,
          onPressed: null, // 비활성화
        ),
        const SizedBox(height: AppSpacing.md),
        SocialLoginButton(
          provider: SocialProvider.google,
          onPressed: onProviderPressed != null
              ? () => onProviderPressed!(SocialProvider.google)
              : null,
        ),
      ],
    );
  }
}
