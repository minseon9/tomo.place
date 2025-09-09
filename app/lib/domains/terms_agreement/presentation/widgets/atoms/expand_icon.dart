import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsExpandIcon extends StatelessWidget {
  const TermsExpandIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: SizedBox(
              width: 8,
              height: 14,
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
