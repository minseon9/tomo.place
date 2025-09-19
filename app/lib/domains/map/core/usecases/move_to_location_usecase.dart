import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/map_controller_service.dart';

/// 특정 위치로 지도 이동 UseCase
class MoveToLocationUseCase {
  final MapControllerService _mapControllerService;
  
  MoveToLocationUseCase(this._mapControllerService);
  
  Future<void> execute(LatLng position) async {
    await _mapControllerService.moveToLocation(position);
  }
}