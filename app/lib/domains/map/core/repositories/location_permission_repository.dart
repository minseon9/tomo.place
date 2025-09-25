import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

import '../../data/repositories/location_permission_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../entities/location_permission_result.dart';

abstract class LocationPermissionRepository<T> {
  Future<LocationPermissionResult> checkPermission();

  Future<LocationPermissionResult> requestPermission();
}

final locationPermissionRepositoryProvider = Provider<LocationPermissionRepository>((ref) {
  return LocationPermissionRepositoryImpl();
});
