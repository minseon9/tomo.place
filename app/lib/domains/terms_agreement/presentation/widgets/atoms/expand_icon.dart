import 'package:flutter/material.dart';
import '../../../../../shared/ui/design_system/tokens/colors.dart';

/// 약관 상세 페이지로 이동하는 확장 아이콘 컴포넌트
/// 
/// 오른쪽 화살표 아이콘을 표시하며, 클릭 시 해당 약관의 상세 페이지로 이동합니다.
class TermsExpandIcon extends StatelessWidget {
  const TermsExpandIcon({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Icon(
          Icons.chevron_right,
          size: 16,
          color: DesignTokens.tomoBlack,
        ),
      ),
    );
  }
}
