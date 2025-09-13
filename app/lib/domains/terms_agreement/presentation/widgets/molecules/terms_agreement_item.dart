import 'package:flutter/material.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_sizing.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/responsive/responsive_typography.dart';
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
        height: ResponsiveSizing.getValueByDevice(
          context,
          mobile: 47.0,
          tablet: 52.0,
        ),
        child: Row(
          children: [
            TermsCheckbox(isChecked: isChecked, isEnabled: false),
            Expanded(
              child: SizedBox(
                height: ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: 48.0,
                  tablet: 53.0,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: ResponsiveSizing.getValueByDevice(
                        context,
                        mobile: 24.0,
                        tablet: 26.0,
                      ),
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          ResponsiveSizing.getValueByDevice(
                            context,
                            mobile: -6.0,
                            tablet: -7.0,
                          ),
                        ),
                        child: Text(
                          title,
                          style:
                              ResponsiveTypography.getResponsiveCaption(
                                context,
                              ).copyWith(
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
