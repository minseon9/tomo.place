import 'package:location/location.dart';

/// 위치 서비스 인터페이스
abstract class LocationService {
  /// 현재 위치를 가져옵니다
  Future<LocationData?> getCurrentLocation();
  
  /// 위치 권한을 요청합니다
  Future<bool> requestPermission();
  
  /// 위치 서비스가 활성화되어 있는지 확인합니다
  Future<bool> isServiceEnabled();
}
