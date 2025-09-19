import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 위치 관련 데이터를 관리하는 Repository 인터페이스
abstract class LocationRepository {
  /// 현재 위치를 가져옵니다
  Future<LatLng?> getCurrentLocation();

  /// 위치 권한을 요청합니다
  Future<bool> requestLocationPermission();
}