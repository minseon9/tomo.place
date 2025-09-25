import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../shared/ui/responsive/responsive_container.dart';
import '../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../../shared/ui/responsive/responsive_spacing.dart';
import '../../../../shared/ui/responsive/responsive_typography.dart';
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
        return true;
      case SocialProvider.google:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      mobileWidthPercent: 0.75,
      tabletWidthPercent: 0.7,
      maxWidth: 400,
      minWidth: 300,
      height: ResponsiveSizing.getValueByDevice(
        context,
        mobile: 45.0,
        tablet: 50.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isLoading || _isDisabled) ? null : onPressed,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: ResponsiveSizing.getResponsiveEdge(
                context,
                top: 14,
                bottom: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  SizedBox(width: ResponsiveSpacing.getResponsive(context, 8)),
                  Text(_getText(), style: _getTextStyle(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isDisabled) {
      return AppColors.tomoDarkGray.withValues(alpha: 0.3);
    }

    switch (provider) {
      case SocialProvider.kakao:
        return AppColors.kakaoYellow;
      case SocialProvider.apple:
      case SocialProvider.google:
        return AppColors.white;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    if (_isDisabled) {
      return ResponsiveTypography.getResponsiveButton(
        context,
      ).copyWith(color: AppColors.tomoDarkGray.withValues(alpha: 0.5));
    }

    switch (provider) {
      case SocialProvider.kakao:
      case SocialProvider.google:
        return ResponsiveTypography.getResponsiveButton(context);
      case SocialProvider.apple:
        return ResponsiveTypography.getResponsiveBody(context);
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
    return SizedBox(width: 18, height: 18, child: _getIconWidget());
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
