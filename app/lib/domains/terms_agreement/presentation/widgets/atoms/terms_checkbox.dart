import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_sizing.dart';

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
        width: ResponsiveSizing.getValueByDevice(
          context,
          mobile: 48.0,
          tablet: 52.0,
        ),
        height: ResponsiveSizing.getValueByDevice(
          context,
          mobile: 48.0,
          tablet: 52.0,
        ),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Center(
          // SVG를 프레임 정중앙에 배치
          child: isChecked
              ? SizedBox(
                  width: ResponsiveSizing.getValueByDevice(
                    context,
                    mobile: 15.0,
                    tablet: 16.0,
                  ),
                  height: ResponsiveSizing.getValueByDevice(
                    context,
                    mobile: 15.0,
                    tablet: 16.0,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/checkbox_checked.svg',
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF146C2E), // #146C2E
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : Container(
                  width: ResponsiveSizing.getValueByDevice(
                    context,
                    mobile: 15.0,
                    tablet: 16.0,
                  ),
                  height: ResponsiveSizing.getValueByDevice(
                    context,
                    mobile: 15.0,
                    tablet: 16.0,
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
        ),
      ),
    );
  }
}
