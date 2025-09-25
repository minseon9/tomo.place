import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends ConsumerWidget{
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialPosition = _getInitialPosition();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 20,
      ),
      myLocationEnabled:  true,
      myLocationButtonEnabled:  false,
      zoomControlsEnabled:  false,
      mapToolbarEnabled: false,
    );
  }

  LatLng _getInitialPosition() {
    return LatLng(37.5665, 126.9780);
  }
}

final mapWidgetProvider = Provider<MapWidget>((ref) {
  return const MapWidget();
});

