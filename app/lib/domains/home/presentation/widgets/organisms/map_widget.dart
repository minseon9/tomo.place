import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../shared/ui/responsive/device_type.dart';
import '../../../../../shared/ui/responsive/responsive_config.dart';
import '../../controller/map_notifier.dart';

class MapWidget extends ConsumerWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);

    if (mapState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return GoogleMap(
      onMapCreated: (controller) {
        mapNotifier.setMapController(controller);
      },
      initialCameraPosition: CameraPosition(
        target: mapState.currentPosition!,
        zoom: 16,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
