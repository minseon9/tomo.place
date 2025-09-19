import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';
import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../../../shared/ui/responsive/responsive_typography.dart';
import '../atoms/category_chip.dart';
import '../../models/category_data.dart';

class MapSearchBar extends StatelessWidget {
  const MapSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: ResponsiveSizing.getResponsivePadding(
            context,
            left: 16,
            top: 8,
            right: 16,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            readOnly: true,
            style: ResponsiveTypography.getResponsiveBody(context).copyWith(
              color: AppColors.tomoBlack,
            ),
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요.',
              hintStyle: ResponsiveTypography.getResponsiveCaption(context).copyWith(
                color: AppColors.tomoDarkGray,
              ),
              suffixIcon: Icon(
                Icons.search,
                color: AppColors.tomoDarkGray,
                size: ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: 24.0,
                  tablet: 26.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: ResponsiveSizing.getResponsivePadding(
                context,
                left: 16,
                top: 12,
                right: 16,
                bottom: 12,
              ),
            ),
          ),
        ),
        
        // 카테고리 칩들
        Container(
          height: ResponsiveSizing.getValueByDevice(
            context,
            mobile: 30.0,
            tablet: 34.0,
          ),
          margin: ResponsiveSizing.getResponsivePadding(
            context,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: CategoryData.defaultCategories.length,
            separatorBuilder: (context, index) => SizedBox(
              width: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 8.0,
                tablet: 10.0,
              ),
            ),
            itemBuilder: (context, index) {
              final category = CategoryData.defaultCategories[index];
              return CategoryChip(
                iconPath: category.iconPath,
                label: category.label,
                isSelected: category.isSelected,
                onTap: () {
                  // TODO: 카테고리 선택 로직 구현
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
