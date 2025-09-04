import 'package:flutter/material.dart';
import 'base_button.dart';
import '../../tokens/colors.dart';

/// BaseButton을 확장한 다양한 버튼 스타일 변형
/// 
/// 디자인 토큰을 적용한 사전 정의된 버튼 스타일들을 제공합니다.
/// 각 변형은 특정 사용 사례에 최적화되어 있습니다.
class ButtonVariants {
  ButtonVariants._();

  /// 주요 액션을 위한 프라이머리 버튼
  static BaseButton primary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return BaseButton(
      onPressed: onPressed,
      backgroundColor: DesignTokens.appColors['primary_200'],
      foregroundColor: DesignTokens.appColors['text_primary'],
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      child: child,
    );
  }

  /// 카카오 브랜드 스타일 버튼
  static BaseButton kakao({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return BaseButton(
      onPressed: onPressed,
      backgroundColor: DesignTokens.socialButtons['kakao_bg'],
      foregroundColor: DesignTokens.socialButtons['kakao_text'],
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      child: child,
    );
  }

  /// 아웃라인 스타일 버튼 (애플, 구글 등에 사용)
  static BaseButton outlined({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return BaseButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: DesignTokens.appColors['text_primary'],
      borderColor: DesignTokens.appColors['border'],
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      child: child,
    );
  }

  /// 보조 액션을 위한 세컨더리 버튼
  static BaseButton secondary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return BaseButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      foregroundColor: DesignTokens.appColors['text_secondary'],
      borderColor: DesignTokens.appColors['border'],
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      child: child,
    );
  }

  /// 텍스트만 있는 버튼 (링크 스타일)
  static BaseButton text({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return BaseButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      foregroundColor: DesignTokens.appColors['primary_200'],
      height: 32,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      elevation: 0,
      child: child,
    );
  }
}
