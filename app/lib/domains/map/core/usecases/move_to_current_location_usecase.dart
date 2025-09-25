import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/exception_handler/exception_notifier.dart';
import '../entities/map_camera.dart';
import '../repositories/location_repository.dart';
import '../repositories/map_control_repository.dart';

class MoveToCurrentLocationUseCase {
  final LocationRepository _locationRepository;
  final MapControlRepository _mapControlRepository;
  final ExceptionNotifier _exceptionNotifier;

  MoveToCurrentLocationUseCase(this._locationRepository, this._mapControlRepository, this._exceptionNotifier);
  
  Future<void> execute() async {
    try {
      final position = await _locationRepository.getCurrentLocation();

      await _mapControlRepository.animateCamera(MapCamera(latitude: position.latitude, longitude: position.longitude, zoom: position.zoom));
    } catch (e) {
      _exceptionNotifier.report(e);
    }
  }
}

final moveToCurrentLocationUseCaseProvider = Provider<MoveToCurrentLocationUseCase>((ref) {
  final locationRepository = ref.read(locationRepositoryProvider);
  final mapRepository = ref.read(mapControlRepositoryProvider);
  final exceptionNotifier = ref.read(exceptionNotifierProvider.notifier);
  return MoveToCurrentLocationUseCase(locationRepository, mapRepository, exceptionNotifier);
});
