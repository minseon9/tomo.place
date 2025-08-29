import 'package:flutter/material.dart';

import '../../../../shared/design_system/tokens/spacing.dart';
import '../../consts/social_label_variant.dart';
import '../../consts/social_provider.dart';
import 'social_login_button.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({
    super.key,
    this.labelVariant = SocialLabelVariant.signup,
    this.onProviderPressed,
  });

  final SocialLabelVariant labelVariant;
  final void Function(String provider)? onProviderPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialLoginButton(
          provider: SocialProvider.kakao,
          onPressed: onProviderPressed != null 
              ? () => onProviderPressed!('kakao')
              : null,
          labelVariant: labelVariant,
        ),
        const SizedBox(height: AppSpacing.md),
        SocialLoginButton(
          provider: SocialProvider.apple,
          onPressed: onProviderPressed != null 
              ? () => onProviderPressed!('apple')
              : null,
          labelVariant: labelVariant,
        ),
        const SizedBox(height: AppSpacing.md),
        SocialLoginButton(
          provider: SocialProvider.google,
          onPressed: onProviderPressed != null 
              ? () => onProviderPressed!('google')
              : null,
          labelVariant: labelVariant,
        ),
      ],
    );
  }
}
