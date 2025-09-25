import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/location_permission_result.dart';
import '../repositories/location_permission_repository.dart';

class CheckLocationPermissionUseCase {
  final LocationPermissionRepository _repository;
  
  CheckLocationPermissionUseCase(this._repository);
  
  Future<LocationPermissionResult> execute() async {
    return await _repository.checkPermission();
  }
}

final checkLocationPermissionUseCaseProvider = Provider<CheckLocationPermissionUseCase>((ref) {
  final repository = ref.read(locationPermissionRepositoryProvider);
  return CheckLocationPermissionUseCase(repository);
});
