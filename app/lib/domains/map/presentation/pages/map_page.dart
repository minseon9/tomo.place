import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../core/usecases/move_to_current_location_usecase.dart';
import '../controllers/location_permission_handler.dart';
import '../controllers/location_permission_notifier.dart';
import '../controllers/map_view_notifier.dart';
import '../models/location_permission_state.dart';
import '../widgets/atoms/my_location_button.dart';
import '../widgets/molecules/map_search_bar.dart';
import '../widgets/organisms/map_widget.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  bool _didRunInitialFlow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationPermissionNotifierProvider.notifier).checkPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionHandler = ref.read(locationPermissionHandlerProvider);
    final mapWidget = ref.read(mapWidgetProvider);

    ref.listen<LocationPermissionState>(
      locationPermissionNotifierProvider,
          (previous, next) {
        switch (next) {
          case LocationPermissionLoading():
            break;
          case LocationPermissionGranted():
            ref.read(moveToCurrentLocationUseCaseProvider).execute().then((_) {
              ref.read(mapViewControllerProvider.notifier).startFollowing();
            });
            break;
          default:
            if (!_didRunInitialFlow) {
              _didRunInitialFlow = true;
              permissionHandler.handleOnAppStart(context, next);
            } else {
              permissionHandler.handleOnResume(context, next);
            }
            break;
        }
      },
    );

    return Stack(
      children: [
        mapWidget,
        SafeArea(
          child: Padding(
            padding: ResponsiveSizing.getResponsiveEdge(context, top: 16),
            child: ref.watch(mapSearchBarProvider),
          ),
        ),
        Positioned(
          right: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
          bottom: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
          child: ref.watch(myLocationButtonProvider),
        ),
      ],
    );
  }
}

final mapPageProvider = Provider<ConsumerStatefulWidget>((ref) {
  return const MapPage();
});
