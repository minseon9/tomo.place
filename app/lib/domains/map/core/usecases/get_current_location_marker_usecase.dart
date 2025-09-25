import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

import '../entities/map_marker.dart';
import '../services/heading_normalizer.dart';

class GetCurrentLocationMarkerUseCase {
  GetCurrentLocationMarkerUseCase();
  
  MapMarker execute(MapPosition? previousPosition, MapPosition currentPosition) {
    final normalized = HeadingNormalizer.normalize(currentPosition.heading);
    final shouldUpdate = previousPosition==null ? true : HeadingNormalizer.hasSignificantChange(
      previous: previousPosition.heading,
      current: normalized,
      thresholdDegrees: 5.0,
    );
    final heading = shouldUpdate ? normalized : previousPosition.heading;

    return MapMarker(
      id: 'current_location_with_direction',
      lat: currentPosition.latitude,
      lng: currentPosition.longitude,
      rotation: heading,
      anchorX: 0.5,
      anchorY: 0.5,
      iconKey: 'current_with_direction',
      title: '내 위치',
    );
  }
}

final getCurrentLocationMarkerProvider = Provider<GetCurrentLocationMarkerUseCase>((ref) {
  return GetCurrentLocationMarkerUseCase();
});
