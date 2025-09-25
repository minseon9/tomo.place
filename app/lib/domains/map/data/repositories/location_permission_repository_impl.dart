import 'package:location/location.dart';

import '../../core/entities/location_permission_result.dart';
import '../../core/repositories/location_permission_repository.dart';
import '../mappers/location_permission_result_mapper.dart';

class LocationPermissionRepositoryImpl implements LocationPermissionRepository {
  LocationPermissionRepositoryImpl();

  final _location = Location();

  @override
  Future<LocationPermissionResult> checkPermission() async {
    return await requestPermission();
  }
  
  @override
  Future<LocationPermissionResult> requestPermission() async {
    final permission = await _location.requestPermission();

    return LocationPermissionResultMapper.fromPermissionStatus(permission);
  }
}
