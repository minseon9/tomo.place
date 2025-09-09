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
    return GestureDetector(
      onTap: hasExpandIcon ? onExpandTap : null,
      behavior: HitTestBehavior.opaque, // 투명한 영역도 터치 감지
      child: SizedBox(
        width: double.infinity,
        height: 47,
        child: Row(
          children: [
            TermsCheckbox(isChecked: isChecked, isEnabled: false),
            Expanded(
              child: SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 24,
                      child: Transform.translate(
                        offset: const Offset(0, -6),
                        child: Text(
                          title,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.tomoBlack,
                            letterSpacing: -0.24,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasExpandIcon) TermsExpandIcon(),
          ],
        ),
      ),
    );
  }
}
