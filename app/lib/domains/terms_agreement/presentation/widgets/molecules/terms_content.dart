import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';

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
                style: AppTypography.header3.copyWith(
                  color: AppColors.tomoBlack,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                entry.value,
                style: AppTypography.body.copyWith(
                  color: AppColors.tomoBlack,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 35),
            ],
          );
        }).toList(),
      ),
    );
  }
}
