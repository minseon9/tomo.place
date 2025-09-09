import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';

class TermsExpandIcon extends StatelessWidget {
  const TermsExpandIcon({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Icon(
          Icons.chevron_right,
          size: 16,
          color: DesignTokens.tomoBlack,
        ),
      ),
    );
  }
}
