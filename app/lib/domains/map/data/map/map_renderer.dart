import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapRenderer {
  Widget renderMap({
    required LatLng initialPosition,
    required double zoom,
    required Function(MapController) onMapCreated,
    bool myLocationEnabled = true,
    bool myLocationButtonEnabled = false,
    bool zoomControlsEnabled = false,
    bool mapToolbarEnabled = false,
  });
}

abstract class MapController {
  Future<void> moveToLocation(LatLng position);

  Future<void> setZoom(double zoom);
  
  Future<LatLng> getCurrentLocation();
  
  Future<void> dispose();
}
