import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/responsive/responsive_sizing.dart';
import '../controllers/map_notifier.dart';
import '../widgets/atoms/my_location_button.dart';
import '../widgets/molecules/map_search_bar.dart';
import '../widgets/organisms/map_widget.dart';
import 'map_page_interface.dart';


class MapPage extends ConsumerStatefulWidget implements MapPageInterface {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();

  @override
  void setOnInitialized(VoidCallback? onInitialized) {
    // NOTE: State에서 관리하므로 여기서는 빈 구현
  }

  @override
  void setOnMoveToCurrentLocation(VoidCallback? onMoveToCurrentLocation) {
    // NOTE: State에서 관리하므로 여기서는 빈 구현
  }
}

class _MapPageState extends ConsumerState<MapPage> {
  VoidCallback? _onInitialized;
  VoidCallback? _onMoveToCurrentLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapNotifierProvider.notifier).initializeMap();
      _onInitialized?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ref.watch(mapWidgetProvider),
        SafeArea(
          child: Padding(
            padding: ResponsiveSizing.getResponsivePadding(
              context,
              top: 16,
            ),
            child: ref.watch(mapSearchBarProvider),
          ),
        ),
        Positioned(
          right: ResponsiveSizing.getValueByDevice(
            context,
            mobile: 36.0,
            tablet: 48.0,
          ),
          bottom: ResponsiveSizing.getValueByDevice(
            context,
            mobile: 36.0,
            tablet: 48.0,
          ),
          child: ref.watch(myLocationButtonProvider),
        ),
      ],
    );
  }

  void setOnInitialized(VoidCallback? onInitialized) {
    _onInitialized = onInitialized;
  }

  void setOnMoveToCurrentLocation(VoidCallback? onMoveToCurrentLocation) {
    _onMoveToCurrentLocation = onMoveToCurrentLocation;
  }
}
