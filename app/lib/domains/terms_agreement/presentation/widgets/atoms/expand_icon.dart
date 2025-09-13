import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../shared/ui/responsive/responsive_sizing.dart';

class TermsExpandIcon extends StatelessWidget {
  const TermsExpandIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: SizedBox(
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
          child: Center(
            child: SizedBox(
              width: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 8.0,
                tablet: 9.0,
              ),
              height: ResponsiveSizing.getValueByDevice(
                context,
                mobile: 14.0,
                tablet: 15.0,
              ),
              child: SvgPicture.asset(
                'assets/icons/expand_right.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFF222222),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
