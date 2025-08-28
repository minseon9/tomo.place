import 'package:flutter/material.dart';

import '../../../../shared/design_system/tokens/spacing.dart';
import '../../consts/social_label_variant.dart';
import '../../consts/social_provider.dart';
import 'social_login_button.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({
    super.key,
    this.includeEmail = false,
    this.labelVariant = SocialLabelVariant.signup,
    this.onKakaoPressed,
    this.onApplePressed,
    this.onGooglePressed,
    this.onEmailPressed,
  });

  final bool includeEmail;
  final SocialLabelVariant labelVariant;
  final VoidCallback? onKakaoPressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onEmailPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialLoginButton(
          provider: SocialProvider.kakao,
          onPressed: onKakaoPressed,
          labelVariant: labelVariant,
        ),
        const SizedBox(height: AppSpacing.md),
        SocialLoginButton(
          provider: SocialProvider.apple,
          onPressed: onApplePressed,
          labelVariant: labelVariant,
        ),
        const SizedBox(height: AppSpacing.md),
        SocialLoginButton(
          provider: SocialProvider.google,
          onPressed: onGooglePressed,
          labelVariant: labelVariant,
        ),
        if (includeEmail) ...[
          const SizedBox(height: AppSpacing.md),
          SocialLoginButton(
            provider: SocialProvider.email,
            onPressed: onEmailPressed,
            labelVariant: labelVariant,
          ),
        ],
      ],
    );
  }
}
