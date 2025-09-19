import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_renderer.dart';

class GoogleMapRenderer implements MapRenderer {
  @override
  Widget renderMap({
    required LatLng initialPosition,
    required double zoom,
    required Function(MapController) onMapCreated,
    MapRendererOptions? options,
  }) {
    return GoogleMap(
      onMapCreated: (controller) {
        onMapCreated(GoogleMapControllerWrapper(controller));
      },
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
}

class GoogleMapControllerWrapper implements MapController {
  final GoogleMapController _controller;
  
  GoogleMapControllerWrapper(this._controller);
  
  @override
  Future<void> moveToLocation(LatLng position) async {
    await _controller.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }
  
  @override
  Future<void> setZoom(double zoom) async {
    await _controller.animateCamera(
      CameraUpdate.zoomTo(zoom),
    );
  }
  
  @override
  Future<LatLng> getCurrentLocation() async {
    final cameraPosition = await _controller.getVisibleRegion();
    return LatLng(
      (cameraPosition.northeast.latitude + cameraPosition.southwest.latitude) / 2,
      (cameraPosition.northeast.longitude + cameraPosition.southwest.longitude) / 2,
    );
  }
  
  
  @override
  Future<void> dispose() async {
  }
}
