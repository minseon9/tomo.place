import 'package:flutter/foundation.dart';

import '../../core/entities/map_marker.dart';

@immutable
class MapViewState {
  final bool isFollowing;

  const MapViewState({
    required this.isFollowing,
  });

  MapViewState copyWith({
    bool? isFollowing,
  }) {
    return MapViewState(
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  static const initial = MapViewState(
    isFollowing: false,
  );
}
