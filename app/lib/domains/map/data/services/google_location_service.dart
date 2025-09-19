import 'package:location/location.dart';

import 'location_service.dart';

/// Google Location 패키지를 사용한 위치 서비스 구현체
class GoogleLocationService implements LocationService {
  final Location _location = Location();
  
  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _location.getLocation().timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> requestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }
  
  @override
  Future<bool> isServiceEnabled() async {
    return await _location.serviceEnabled();
  }
}
