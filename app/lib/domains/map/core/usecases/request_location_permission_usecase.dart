import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/location_permission_result.dart';
import '../repositories/location_permission_repository.dart';

class RequestLocationPermissionUseCase {
  final LocationPermissionRepository _repository;

  RequestLocationPermissionUseCase(this._repository);
  
  Future<LocationPermissionResult> execute() async {
    return await _repository.requestPermission();
  }
}

final requestLocationPermissionUseCaseProvider = Provider<RequestLocationPermissionUseCase>((ref) {
  final repository = ref.read(locationPermissionRepositoryProvider);
  return RequestLocationPermissionUseCase(repository);
});
