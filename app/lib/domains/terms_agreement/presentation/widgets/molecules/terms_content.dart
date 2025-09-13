import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/responsive/responsive_spacing.dart';
import '../../../../../shared/ui/responsive/responsive_typography.dart';

class TermsContent extends StatelessWidget {
  const TermsContent({super.key, required this.contentMap});

  final Map<String, String> contentMap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentMap.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: ResponsiveTypography.getResponsiveHeader3(
                  context,
                ).copyWith(color: AppColors.tomoBlack, letterSpacing: -0.4),
              ),
              SizedBox(height: ResponsiveSpacing.getResponsive(context, 10)),
              Text(
                entry.value,
                style: ResponsiveTypography.getResponsiveBody(context).copyWith(
                  color: AppColors.tomoBlack,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.getResponsive(context, 35)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
