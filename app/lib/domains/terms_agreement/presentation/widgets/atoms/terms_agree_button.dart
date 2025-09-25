import 'package:flutter/material.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_sizing.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/responsive/responsive_container.dart';
import '../../../../../shared/ui/responsive/responsive_typography.dart';

class TermsAgreeButton extends StatelessWidget {
  const TermsAgreeButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      mobileWidthPercent: 0.75,
      tabletWidthPercent: 0.7,
      maxWidth: 350,
      minWidth: 280,
      height: ResponsiveSizing.getValueByDevice(
        context,
        mobile: 45.0,
        tablet: 50.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tomoPrimary300,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(6.0),
            child: Center(
              child: Text(
                '모두 동의합니다 !',
                style: ResponsiveTypography.getResponsiveButton(context)
                    .copyWith(
                      color: const Color.fromRGBO(0, 0, 0, 0.85),
                      letterSpacing: -0.28,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
