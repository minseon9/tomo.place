import 'package:location/location.dart';

import '../../core/entities/map_position.dart';
import '../../core/exceptions/location_exception.dart';
import '../../core/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl();

  final Location _location = Location();

  @override
  Future<MapPosition> getCurrentLocation() async {
    bool isServiceEnabled = await _location.serviceEnabled();
    if (!isServiceEnabled) {
      throw LocationException.permissionDenied(message: "위치 서비스 사용 권한이 없습니다.");
    }

    try {
      final locationData = await _location.getLocation()
          .timeout(const Duration(seconds: 1));

      return MapPosition(latitude: locationData.latitude!, longitude: locationData.longitude!, heading: locationData.heading!);
    } catch (e) {
      throw LocationException.notFound(message: "현재 위치를 찾을 수 없습니다.");
    }
 }
}
