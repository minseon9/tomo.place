import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/responsive/responsive_sizing.dart';
import '../widgets/atoms/my_location_button.dart';
import '../widgets/molecules/map_search_bar.dart';
import '../widgets/organisms/map_widget.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  Widget build(BuildContext context) {
    final mapWidget = ref.read(mapWidgetProvider);

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
