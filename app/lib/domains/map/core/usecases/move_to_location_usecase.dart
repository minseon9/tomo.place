import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

import '../../../../shared/exception_handler/exception_notifier.dart';
import '../entities/map_camera.dart';
import '../repositories/map_control_repository.dart';

class MoveToLocationUseCase {
  final MapControlRepository _mapControlRepository;
  final ExceptionNotifier _exceptionNotifier;

  MoveToLocationUseCase(this._mapControlRepository, this._exceptionNotifier);
  
  Future<void> execute(MapPosition position) async {
    try {
      await _mapControlRepository.animateCamera(MapCamera(latitude: position.latitude, longitude: position.longitude, zoom: position.zoom));
    } catch (e) {
      _exceptionNotifier.report(e);
    }
  }
}

final moveToLocationUseCaseProvider = Provider<MoveToLocationUseCase>((ref) {
  final mapRepository = ref.read(mapControlRepositoryProvider);
  final exceptionNotifier = ref.read(exceptionNotifierProvider.notifier);
  return MoveToLocationUseCase(mapRepository, exceptionNotifier);
});
