import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/exception_handler/exception_notifier.dart';
import '../../../data/map/map_renderer.dart';
import '../../controllers/map_notifier.dart';
import '../../models/map_state.dart';
import '../../providers/map_providers.dart';

class MapWidget extends ConsumerWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapRenderer = ref.watch(mapRendererProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);

    if (mapState is MapLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // ExceptionNotifier를 통해 에러 처리 (Auth 패턴과 일관성)
    final exception = ref.watch(exceptionNotifierProvider);
    if (exception != null) {
      return Center(child: Text('Error: ${exception.message}'));
    }
    
    if (mapState is MapReady) {
      return mapRenderer.renderMap(
        initialPosition: mapState.currentPosition,
        zoom: 16,
        onMapCreated: (controller) {
          // GoogleMap 위젯에서 Controller를 받아서 MapNotifier에 전달
          mapNotifier.setMapController(controller);
        },
        options: const MapRendererOptions(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

final mapWidgetProvider = Provider<Widget>((ref) {
  return const MapWidget();
});
