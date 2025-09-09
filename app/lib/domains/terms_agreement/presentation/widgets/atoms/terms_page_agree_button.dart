import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';

class TermsPageAgreeButton extends StatelessWidget {
  const TermsPageAgreeButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.tomoPrimary300, // #ebd9b8
        borderRadius: BorderRadius.circular(20.0), // rounded-[20px]
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.5), // rgba(0,0,0,0.5)
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20.0),
          child: Center(
            child: Text(
              '동의',
              style: AppTypography.button.copyWith(letterSpacing: -0.28),
            ),
          ),
        ),
      ),
    );
  }
}
