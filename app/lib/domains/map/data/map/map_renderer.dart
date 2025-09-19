import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRendererOptions {
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  
  const MapRendererOptions({
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
  });
}

abstract class MapRenderer {
  Widget renderMap({
    required LatLng initialPosition,
    required double zoom,
    required Function(MapController) onMapCreated,
    MapRendererOptions? options,
  });
}

abstract class MapController {
  Future<void> moveToLocation(LatLng position);

  Future<void> setZoom(double zoom);
  
  Future<LatLng> getCurrentLocation();
  
  Future<void> dispose();
}
