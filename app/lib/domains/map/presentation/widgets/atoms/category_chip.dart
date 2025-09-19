import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../../../shared/ui/responsive/responsive_typography.dart';

class CategoryChip extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.iconPath,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: ResponsiveSizing.getValueByDevice(
          context,
          mobile: 30.0,
          tablet: 34.0,
        ),
        padding: ResponsiveSizing.getResponsivePadding(
          context,
          left: 8,
          top: 6,
          right: 8,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFC9C4D1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 24.0,
                tablet: 26.0,
              ),
              height: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 24.0,
                tablet: 26.0,
              ),
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  AppColors.tomoDarkGray,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(
              width: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 4.0,
                tablet: 5.0,
              ),
            ),
            Text(
              label,
              style: ResponsiveTypography.getResponsiveCaption(context).copyWith(
                color: AppColors.tomoBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category Chip Provider
/// 
/// CategoryChip을 Provider로 제공하여 의존성 주입과 테스트 용이성을 확보합니다.
final categoryChipProvider = Provider<Widget Function({
  required String iconPath,
  required String label,
  bool isSelected,
  VoidCallback? onTap,
})>((ref) {
  return ({
    required String iconPath,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return CategoryChip(
      iconPath: iconPath,
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  };
});
