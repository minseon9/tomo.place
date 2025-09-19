import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/map/map_renderer.dart';

/// 지도 컨트롤러 관련 서비스 인터페이스
abstract class MapControllerService {
  /// 특정 위치로 지도를 이동합니다
  Future<void> moveToLocation(LatLng position);

  /// 줌 레벨을 설정합니다
  Future<void> setZoom(double zoom);
  
  /// 지도 컨트롤러를 설정합니다
  void setMapController(MapController controller);
}
