import 'package:flutter/material.dart';
import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';
import '../atoms/terms_checkbox.dart';
import '../atoms/expand_icon.dart';

/// 약관 동의 항목 컴포넌트
/// 
/// 체크박스, 약관 제목, 확장 아이콘을 포함하는 개별 약관 동의 항목입니다.
/// 체크박스는 비활성화되어 있으며, 확장 아이콘은 조건부로 표시됩니다.
class TermsAgreementItem extends StatelessWidget {
  const TermsAgreementItem({
    super.key,
    required this.title,
    required this.isChecked,
    this.hasExpandIcon = false,
    this.onExpandTap,
  });

  final String title;
  final bool isChecked;
  final bool hasExpandIcon;
  final VoidCallback? onExpandTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Row(
        children: [
          // 체크박스 (비활성화)
          TermsCheckbox(
            isChecked: isChecked,
            isEnabled: false, // 항상 비활성화
          ),
          
          const SizedBox(width: 1),
          
          // 텍스트
          Expanded(
            child: Text(
              title,
              style: AppTypography.caption.copyWith(
                color: DesignTokens.tomoBlack,
                letterSpacing: -0.24,
              ),
            ),
          ),
          
          // 확장 아이콘 (조건부)
          if (hasExpandIcon)
            TermsExpandIcon(onTap: onExpandTap),
        ],
      ),
    );
  }
}
