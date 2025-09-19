import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/exception_handler/models/exception_interface.dart';
import '../../core/services/map_controller_service.dart';
import '../map/map_renderer.dart';

/// 지도 컨트롤러 서비스 구현체
class MapControllerServiceImpl implements MapControllerService {
  // MapController는 MapNotifier에서 주입받음
  MapController? _mapController;
  
  @override
  void setMapController(MapController controller) {
    _mapController = controller;
  }
  
  @override
  Future<void> moveToLocation(LatLng position) async {
    if (_mapController == null) {
      throw MapControllerNotReadyException();
    }
    await _mapController!.moveToLocation(position);
  }
  
  @override
  Future<void> setZoom(double zoom) async {
    if (_mapController == null) {
      throw MapControllerNotReadyException();
    }
    await _mapController!.setZoom(zoom);
  }
}

/// Map Controller가 준비되지 않은 예외
class MapControllerNotReadyException implements ExceptionInterface {
  @override
  String get message => 'Map controller is not ready';
  
  @override
  String get userMessage => '지도가 아직 준비되지 않았습니다. 잠시 후 다시 시도해주세요.';
}
