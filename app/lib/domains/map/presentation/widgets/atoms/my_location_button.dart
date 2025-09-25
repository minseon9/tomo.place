import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

import '../../../../../shared/ui/responsive/responsive_sizing.dart';

class MyLocationButton extends ConsumerWidget {
  const MyLocationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonSize = ResponsiveSizing.getValueByDevice(
      context,
      mobile: 36.0,
      tablet: 42.0,
    );
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: ResponsiveSizing.getValueByDevice(
              context,
              mobile: 8.0,
              tablet: 10.0,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: () => {
            // FIXME: onTap callback 구현
          },
          child: Center(
            child: _getMyLocationIcon(context),
          ),
        ),
      ),
    );
  }

  SvgPicture _getMyLocationIcon(BuildContext context) {
    final iconSize = ResponsiveSizing.getValueByDevice(
      context,
      mobile: 20.0,
      tablet: 26.0,
    );

    return SvgPicture.asset(
      'assets/icons/location_button_icon.svg',
      width: iconSize,
      height: iconSize,
      colorFilter: ColorFilter.mode(const Color(0xFF6393F2), BlendMode.srcIn), // 모든 도형 색을 red로
    );
  }
}

final myLocationButtonProvider = Provider<Widget>((ref) {
  return const MyLocationButton();
});
