import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/entities/map_marker.dart';
import '../models/map_view_state.dart';

class MapViewController extends StateNotifier<MapViewState> {
  MapViewController() : super(MapViewState.initial);

  void startFollowing() {
    if (!state.isFollowing) {
      state = state.copyWith(isFollowing: true);
    }
  }

  void stopFollowing() {
    if (state.isFollowing) {
      state = state.copyWith(isFollowing: false);
    }
  }
}

final mapViewControllerProvider =
    StateNotifierProvider<MapViewController, MapViewState>((ref) {
  return MapViewController();
});
