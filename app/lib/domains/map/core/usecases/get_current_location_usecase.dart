import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/exception_handler/exceptions/unknown_exception.dart';
import '../../../../shared/exception_handler/models/exception_interface.dart';
import '../../repositories/location_repository.dart';

/// 현재 위치 조회 UseCase
class GetCurrentLocationUseCase {
  final LocationRepository _locationRepository;
  
  GetCurrentLocationUseCase(this._locationRepository);
  
  Future<LatLng> execute() async {
    final hasPermission = await _locationRepository.requestLocationPermission();
    if (!hasPermission) {
      throw LocationPermissionDeniedException();
    }
    
    final position = await _locationRepository.getCurrentLocation();
    if (position == null) {
      throw LocationNotFoundException();
    }
    
    return position;
  }
}

/// 위치 권한 거부 예외
class LocationPermissionDeniedException implements ExceptionInterface {
  @override
  String get message => 'Location permission denied';
  
  @override
  String get userMessage => '위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해주세요.';
}

/// 위치를 찾을 수 없는 예외
class LocationNotFoundException implements ExceptionInterface {
  @override
  String get message => 'Location not found';
  
  @override
  String get userMessage => '현재 위치를 찾을 수 없습니다. 잠시 후 다시 시도해주세요.';
}