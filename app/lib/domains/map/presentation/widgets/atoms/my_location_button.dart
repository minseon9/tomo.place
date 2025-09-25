import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../core/usecases/move_to_current_location_usecase.dart';
import '../../controllers/location_permission_handler.dart';
import '../../controllers/location_permission_notifier.dart';
import '../../controllers/map_view_notifier.dart';

class MyLocationButton extends ConsumerWidget {
  const MyLocationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(locationPermissionNotifierProvider);
    final permissionHandler = ref.read(locationPermissionHandlerProvider);
    final moveToCurrentLocation = ref.watch(moveToCurrentLocationUseCaseProvider);
    final hasPermission = permissionState.hasLocationPermission;

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
          onTap: hasPermission ? () async {
            try {
              // follow 모드 시작
              ref.read(mapViewControllerProvider.notifier).startFollowing();
              await moveToCurrentLocation.execute();
            } catch (_) {
              // ignore
            }
          } : () => permissionHandler.handleOnAction(context, permissionState),
          child: Center(
            child: _getMyLocationIcon(context, hasPermission),
          ),
        ),
      ),
    );
  }

  SvgPicture _getMyLocationIcon(BuildContext context, bool hasPermission) {
    final iconSize = ResponsiveSizing.getValueByDevice(
      context,
      mobile: 20.0,
      tablet: 26.0,
    );

    return SvgPicture.asset(
      'assets/icons/location_button_icon.svg',
      width: iconSize,
      height: iconSize,
      colorFilter: ColorFilter.mode(hasPermission ? const Color(0xFF6393F2) : const Color(0xB3D32F2F), BlendMode.srcIn),
    );
  }
}

final myLocationButtonProvider = Provider<Widget>((ref) {
  return const MyLocationButton();
});
