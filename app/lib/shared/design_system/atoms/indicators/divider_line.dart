import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// 구분선 컴포넌트
/// 
/// 회원가입 화면의 시각적 구분을 위한 선입니다.
class DividerLine extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  
  const DividerLine({
    super.key,
    this.width,
    this.height = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color ?? DesignTokens.tomoDarkGray.withValues(alpha: 0.3),
      ),
    );
  }
}
