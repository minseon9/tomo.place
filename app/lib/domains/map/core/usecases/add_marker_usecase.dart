import '../entities/map_marker.dart';
import '../repositories/map_repository.dart';

/// 지도에 마커를 추가하는 Use Case
class AddMarkerUseCase {
  const AddMarkerUseCase(this._mapRepository);

  final MapRepository _mapRepository;

  /// 지도에 마커를 추가합니다
  /// 
  /// [marker] 추가할 마커
  Future<void> execute(MapMarker marker) async {
    try {
      await _mapRepository.addMarker(marker);
    } catch (e) {
      // 에러 처리 (필요시 Exception 던지기)
      rethrow;
    }
  }

  /// 지도에서 마커를 제거합니다
  /// 
  /// [markerId] 제거할 마커의 ID
  Future<void> removeMarker(String markerId) async {
    try {
      await _mapRepository.removeMarker(markerId);
    } catch (e) {
      rethrow;
    }
  }

  /// 모든 마커를 제거합니다
  Future<void> clearAllMarkers() async {
    try {
      await _mapRepository.clearMarkers();
    } catch (e) {
      rethrow;
    }
  }
}
