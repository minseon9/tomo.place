import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../controller/map_notifier.dart';

class MyLocationButton extends ConsumerWidget {
  const MyLocationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    
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
        color: Colors.white,
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
          onTap: () => mapNotifier.moveToCurrentLocation(),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/location_button_icon.svg',
              width: buttonSize,
              height: buttonSize,
            ),
          ),
        ),
      ),
    );
  }
}
