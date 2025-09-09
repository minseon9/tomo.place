import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';
import '../atoms/expand_icon.dart';
import '../atoms/terms_checkbox.dart';

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
          TermsCheckbox(isChecked: isChecked, isEnabled: false),

          const SizedBox(width: 1),

          Expanded(
            child: Text(
              title,
              style: AppTypography.caption.copyWith(
                color: DesignTokens.tomoBlack,
                letterSpacing: -0.24,
              ),
            ),
          ),

          if (hasExpandIcon) TermsExpandIcon(onTap: onExpandTap),
        ],
      ),
    );
  }
}
