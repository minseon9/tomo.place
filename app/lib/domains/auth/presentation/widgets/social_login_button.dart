import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../../../shared/design_system/tokens/sizes.dart';
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
          onTap: isLoading ? null : onPressed,
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
                Text(
                  _getText(),
                  style: _getTextStyle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (provider) {
      case SocialProvider.kakao:
        return DesignTokens.kakaoYellow;
      case SocialProvider.apple:
      case SocialProvider.google:
      case SocialProvider.email:
        return DesignTokens.white;
    }
  }

  TextStyle _getTextStyle() {
    switch (provider) {
      case SocialProvider.kakao:
      case SocialProvider.google:
      case SocialProvider.email:
        return AppTypography.button;
      case SocialProvider.apple:
        return AppTypography.body; // 애플은 16px Regular 사용
    }
  }

  String _getText() {
    switch (provider) {
      case SocialProvider.kakao:
        return labelVariant == SocialLabelVariant.login 
            ? '카카오 로그인' 
            : '카카오로 시작하기';
      case SocialProvider.apple:
        return labelVariant == SocialLabelVariant.login 
            ? '애플 로그인' 
            : '애플로 시작하기';
      case SocialProvider.google:
        return labelVariant == SocialLabelVariant.login 
            ? '구글 로그인' 
            : '구글로 시작하기';
      case SocialProvider.email:
        return labelVariant == SocialLabelVariant.login 
            ? '이메일로 로그인' 
            : '이메일로 시작하기';
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
      case SocialProvider.email:
        return const SizedBox.shrink(); // 이메일 버튼은 아이콘 없음
    }
  }
}


