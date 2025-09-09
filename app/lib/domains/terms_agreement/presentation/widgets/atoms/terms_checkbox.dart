import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.isChecked,
    this.isEnabled = true,
    this.onChanged,
  });

  final bool isChecked;
  final bool isEnabled;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? () => onChanged?.call(!isChecked) : null,
      child: Container(
        width: 48, // Figma: 48x48px 전체 프레임
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Center( // SVG를 프레임 정중앙에 배치
          child: isChecked
              ? SizedBox(
                  width: 15, // SVG 크기를 15x15로 줄임
                  height: 15,
                  child: SvgPicture.asset(
                    'assets/icons/checkbox_checked.svg',
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF146C2E), // #146C2E
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
        ),
      ),
    );
  }
}
