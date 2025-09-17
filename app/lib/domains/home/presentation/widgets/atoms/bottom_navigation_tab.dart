import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../../../shared/ui/responsive/responsive_typography.dart';

class BottomNavigationTab extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const BottomNavigationTab({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  // FIXME: isSelected일 때 애니메이션 ? 색감 ?
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: ResponsiveSizing.getValueByDevice(
          context,
          mobile: 88.0,
          tablet: 96.0,
        ),
        padding: ResponsiveSizing.getResponsivePadding(
          context,
          top: 10,
          bottom: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 32.0,
                tablet: 36.0,
              ),
              height: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 32.0,
                tablet: 36.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: ResponsiveSizing.getValueByDevice(
                    context,
                    mobile: 24.0,
                    tablet: 28.0,
                  ),
                  height: ResponsiveSizing.getValueByDevice(
                    context,
                    mobile: 24.0,
                    tablet: 28.0,
                  ),
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.tomoDarkGray : AppColors.tomoDarkGray,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 4.0,
                tablet: 5.0,
              ),
            ),
            // Label
            Text(
              label,
              style: ResponsiveTypography.getResponsiveCaption(context).copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.tomoDarkGray,
                letterSpacing: -0.24,
                height: 1.0,
              ),
            ),
            SizedBox(
              height: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 12.0,
                tablet: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

