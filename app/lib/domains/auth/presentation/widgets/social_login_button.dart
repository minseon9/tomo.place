import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../shared/ui/design_system/tokens/sizes.dart';
import '../../../../shared/ui/design_system/tokens/spacing.dart';
import '../../../../shared/ui/design_system/tokens/typography.dart';
import '../../consts/social_provider.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  bool get _isDisabled {
    switch (provider) {
      case SocialProvider.kakao:
      case SocialProvider.apple:
        return true; // 아직 지원하지 않음
      case SocialProvider.google:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.buttonWidth,
      height: AppSizes.buttonHeight,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isLoading || _isDisabled) ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.buttonPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(),
                const SizedBox(width: AppSpacing.sm),
                Text(_getText(), style: _getTextStyle()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isDisabled) {
      return DesignTokens.tomoDarkGray.withValues(alpha: 0.3);
    }

    switch (provider) {
      case SocialProvider.kakao:
        return DesignTokens.kakaoYellow;
      case SocialProvider.apple:
      case SocialProvider.google:
        return DesignTokens.white;
    }
  }

  TextStyle _getTextStyle() {
    if (_isDisabled) {
      return AppTypography.button.copyWith(
        color: DesignTokens.tomoDarkGray.withValues(alpha: 0.5),
      );
    }

    switch (provider) {
      case SocialProvider.kakao:
      case SocialProvider.google:
        return AppTypography.button;
      case SocialProvider.apple:
        return AppTypography.body; // 애플은 16px Regular 사용
    }
  }

  String _getText() {
    if (_isDisabled) {
      switch (provider) {
        case SocialProvider.kakao:
          return '카카오로 시작하기 (준비 중)';
        case SocialProvider.apple:
          return '애플로 시작하기 (준비 중)';
        default:
          return '';
      }
    }

    switch (provider) {
      case SocialProvider.kakao:
        return '카카오로 시작하기';
      case SocialProvider.apple:
        return '애플로 시작하기';
      case SocialProvider.google:
        return '구글로 시작하기';
    }
  }

  Widget _buildIcon() {
    return SizedBox(
      width: AppSizes.iconSize,
      height: AppSizes.iconSize,
      child: _getIconWidget(),
    );
  }

  Widget _getIconWidget() {
    switch (provider) {
      case SocialProvider.kakao:
        return SvgPicture.asset('assets/icons/kakao_logo.svg');
      case SocialProvider.apple:
        return SvgPicture.asset('assets/icons/apple_logo.svg');
      case SocialProvider.google:
        return SvgPicture.asset('assets/icons/google_logo.svg');
    }
  }
}
