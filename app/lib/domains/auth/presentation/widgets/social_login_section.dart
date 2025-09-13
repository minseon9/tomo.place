import 'package:flutter/material.dart';

import '../../../../shared/ui/responsive/responsive_spacing.dart';
import '../../consts/social_provider.dart';
import 'social_login_button.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key, this.onProviderPressed});

  final void Function(SocialProvider provider)? onProviderPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialLoginButton(provider: SocialProvider.kakao, onPressed: null),
        SizedBox(height: ResponsiveSpacing.getResponsive(context, 16)),
        SocialLoginButton(provider: SocialProvider.apple, onPressed: null),
        SizedBox(height: ResponsiveSpacing.getResponsive(context, 16)),
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
