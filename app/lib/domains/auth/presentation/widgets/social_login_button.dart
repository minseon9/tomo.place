import 'package:flutter/material.dart';

import '../../../../shared/design_system/atoms/buttons/button_variants.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../../../shared/design_system/tokens/typography.dart';
import '../../consts/social_provider.dart';
import '../../consts/social_label_variant.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.labelVariant = SocialLabelVariant.signup,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final SocialLabelVariant labelVariant;

  @override
  Widget build(BuildContext context) {
    final config = _getProviderConfig(provider, labelVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.buttonGap,
      ),
      child: config.buttonBuilder(
        onPressed: onPressed,
        isLoading: isLoading,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            config.icon,
            const SizedBox(width: 8),
            Text(
              config.text,
              style: AppTypography.buttonMedium,
            ),
          ],
        ),
      ),
    );
  }

  _SocialButtonConfig _getProviderConfig(
    SocialProvider provider,
    SocialLabelVariant variant,
  ) {
    switch (provider) {
      case SocialProvider.kakao:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '카카오 로그인' : '카카오로 시작하기',
          icon: _buildIcon('💬', Colors.black),
          buttonBuilder: ButtonVariants.kakao,
        );
      case SocialProvider.apple:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '애플 로그인' : '애플로 시작하기',
          icon: _buildIcon('🍎', Colors.black),
          buttonBuilder: ButtonVariants.outlined,
        );
      case SocialProvider.google:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '구글 로그인' : '구글로 시작하기',
          icon: _buildIcon('G', Colors.black),
          buttonBuilder: ButtonVariants.outlined,
        );
      case SocialProvider.email:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '이메일로 로그인' : '이메일로 시작하기',
          icon: const Icon(Icons.email, size: 20, color: Colors.black),
          buttonBuilder: ButtonVariants.outlined,
        );
    }
  }

  Widget _buildIcon(String emoji, Color color) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }
}

class _SocialButtonConfig {
  final String text;
  final Widget icon;
  final Widget Function({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading,
    double? width,
  }) buttonBuilder;

  _SocialButtonConfig({
    required this.text,
    required this.icon,
    required this.buttonBuilder,
  });
}


