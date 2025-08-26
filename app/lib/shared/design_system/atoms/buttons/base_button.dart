import 'package:flutter/material.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// 모든 버튼의 기본이 되는 순수 UI 컴포넌트
/// 
/// 비즈니스 로직에 의존하지 않으며, 오직 UI 표현만 담당합니다.
/// 다른 프로젝트에서도 재사용 가능한 완전히 독립적인 컴포넌트입니다.
class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.button,
    this.height = 52.0,
    this.width,
    this.isLoading = false,
    this.isDisabled = false,
    this.elevation = 0.0,
    this.padding,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double height;
  final double? width;
  final bool isLoading;
  final bool isDisabled;
  final double elevation;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;
    
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null 
              ? BorderSide(color: borderColor!, width: 1.0)
              : BorderSide.none,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? Colors.white,
          ),
        ),
      );
    }
    return child;
  }
}
