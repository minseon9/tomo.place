import 'package:flutter/foundation.dart';

import '../../core/entities/map_marker.dart';

@immutable
class MapViewState {
  final Set<MapMarker> markers;
  final bool isFollowing;

  const MapViewState({
    required this.markers,
    required this.isFollowing,
  });

  MapViewState copyWith({
    Set<MapMarker>? markers,
    bool? isFollowing,
  }) {
    return MapViewState(
      markers: markers ?? this.markers,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  static const initial = MapViewState(
    markers: <MapMarker>{},
    isFollowing: false,
  );
}
