import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/radius.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';

class TermsAgreeButton extends StatelessWidget {
  const TermsAgreeButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 45,
      decoration: BoxDecoration(
        color: DesignTokens.tomoPrimary300,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Center(
            child: Text(
              '모두 동의합니다 !',
              style: AppTypography.button.copyWith(
                color: DesignTokens.socialButtons['kakao_text'],
                letterSpacing: -0.28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
