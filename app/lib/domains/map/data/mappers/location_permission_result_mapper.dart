import 'package:location/location.dart';

import '../../core/entities/location_permission_result.dart';

class LocationPermissionResultMapper {
  static LocationPermissionResult fromPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.deniedForever:
        return const LocationPermissionResult(
          hasLocationPermission: false,
          hasPartialPermission: false,
          canRequestInApp: false,
          message: '위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.',
        );
      case PermissionStatus.denied:
        return const LocationPermissionResult(
        hasLocationPermission: false,
        hasPartialPermission: false,
        canRequestInApp: true,
      );
      case PermissionStatus.grantedLimited:
        return const LocationPermissionResult(
        hasLocationPermission: true,
        hasPartialPermission: true,
        canRequestInApp: false,
        message: '위치가 정확하지 않을 수 있습니다.',
      );
      case PermissionStatus.granted:
        return const LocationPermissionResult(
          hasLocationPermission: true,
          hasPartialPermission: false,
          canRequestInApp: false,
        );
      default:
        return const LocationPermissionResult(
          hasLocationPermission: false,
          hasPartialPermission: false,
          canRequestInApp: false,
          message: '위치 권한 상태를 확인할 수 없습니다.',
        );

    }
  }
}
