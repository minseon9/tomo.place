import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/entities/map_marker.dart';
import '../../../../core/repositories/map_control_repository.dart';
import '../../../controllers/map_view_notifier.dart';
import '../map_widget.dart';
import 'google_map_icon_registry.dart';

class GoogleMapWidget extends MapWidget {
  const GoogleMapWidget({super.key});

  @override
  Widget renderMap({
    required WidgetRef ref,
    required double zoom,
    MapRenderOptions? options,
    Set<MapMarker>? markers,
  }) {
    final initialPosition = _getInitialPosition();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: zoom,
      ),
      onMapCreated: (controller) async {
        final repository = ref.read(mapControlRepositoryProvider);
        repository.setController(controller);
      },
      onCameraMoveStarted: () {
        ref.read(mapViewControllerProvider.notifier).stopFollowing();
      },
      myLocationEnabled: options?.myLocationEnabled ?? true,
      myLocationButtonEnabled: options?.myLocationButtonEnabled ?? false,
      zoomControlsEnabled: options?.zoomControlsEnabled ?? false,
      mapToolbarEnabled: options?.mapToolbarEnabled ?? false,
      markers: _buildMarkers(ref, markers),
    );
  }

  LatLng _getInitialPosition() {
    return LatLng(37.5665, 126.9780);
  }

  Set<Marker> _buildMarkers(WidgetRef ref, Set<MapMarker>? markers) {
    if (markers == null) return const <Marker>{};

    final registry = ref.read(mapIconRegistryProvider);
    return {
      for (final m in markers)
        Marker(
          markerId: MarkerId(m.id),
          position: LatLng(m.lat, m.lng),
          rotation: m.rotation,
          anchor: Offset(m.anchorX, m.anchorY),
          icon: () {
            final icon = registry.get(m.iconKey);
            if (icon is GoogleMapIcon) return icon.bitmap;
            return BitmapDescriptor.defaultMarker;
          }(),
          infoWindow: InfoWindow(title: m.title, snippet: m.snippet),
        ),
    };
  }
}
