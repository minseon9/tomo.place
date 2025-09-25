import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

import '../../data/repositories/location_repository_impl.dart';

abstract class LocationRepository<T> {
  Future<MapPosition> getCurrentLocation();
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});
