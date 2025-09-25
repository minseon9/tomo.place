import 'package:flutter/material.dart';

import '../design_system/tokens/colors.dart';
import '../design_system/tokens/typography.dart';
import '../responsive/responsive_sizing.dart';

class AppToast extends StatelessWidget {
  final String message;
  final Duration duration;

  const AppToast({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: ResponsiveSizing.getResponsiveSymmetricEdge(context, vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.tomoBlack.withAlpha(128),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          message,
          style: AppTypography.button.copyWith(
            color: AppColors.tomoWhite,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  } 

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Center(
            child: AppToast(message: message),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: ResponsiveSizing.getResponsiveEdge(context, bottom: 100),
        ),
      );
  }
}
