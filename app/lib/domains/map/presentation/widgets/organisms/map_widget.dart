import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'google/google_map_widget.dart';

class MapRenderOptions {
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;

  const MapRenderOptions({
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
  });
}

abstract class MapWidget extends ConsumerWidget{
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return renderMap(
      ref: ref,
      zoom: 16,
      options: const MapRenderOptions(
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }

  Widget renderMap({
    required WidgetRef ref,
    required double zoom,
    MapRenderOptions? options,
  });
}

final mapWidgetProvider = Provider<MapWidget>((ref) {
  return const GoogleMapWidget();
});

