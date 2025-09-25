import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../map_widget.dart';

class GoogleMapWidget extends MapWidget {
  const GoogleMapWidget({super.key});

  @override
  Widget renderMap({
    required WidgetRef ref,
    required double zoom,
    MapRenderOptions? options,
  }) {
    final initialPosition = _getInitialPosition();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: zoom,
      ),
      myLocationEnabled: options?.myLocationEnabled ?? true,
      myLocationButtonEnabled: options?.myLocationButtonEnabled ?? false,
      zoomControlsEnabled: options?.zoomControlsEnabled ?? false,
      mapToolbarEnabled: options?.mapToolbarEnabled ?? false,
    );
  }

  LatLng _getInitialPosition() {
    return LatLng(37.5665, 126.9780);
  }
}
