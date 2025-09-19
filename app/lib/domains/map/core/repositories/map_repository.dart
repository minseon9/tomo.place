import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/map_position.dart';
import '../entities/map_marker.dart';

/// 지도 관련 데이터를 관리하는 Repository 인터페이스
abstract class MapRepository {
  /// 현재 위치를 가져옵니다
  Future<MapPosition?> getCurrentPosition();

  /// 특정 위치로 지도를 이동합니다
  Future<void> moveToPosition(MapPosition position);

  /// 마커를 추가합니다
  Future<void> addMarker(MapMarker marker);

  /// 마커를 제거합니다
  Future<void> removeMarker(String markerId);

  /// 모든 마커를 제거합니다
  Future<void> clearMarkers();

  /// 줌 레벨을 설정합니다
  Future<void> setZoom(double zoom);

  /// 지도 컨트롤러를 설정합니다
  Future<void> setMapController(dynamic controller);
}
