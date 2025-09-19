import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../core/repositories/location_repository.dart';
import '../services/location_service.dart';

/// 위치 Repository 구현체
class LocationRepositoryImpl implements LocationRepository {
  final LocationService _locationService;
  
  LocationRepositoryImpl(this._locationService);
  
  @override
  Future<LatLng?> getCurrentLocation() async {
    final locationData = await _locationService.getCurrentLocation();
    return locationData != null 
        ? LatLng(locationData.latitude!, locationData.longitude!)
        : null;
  }
  
  @override
  Future<bool> requestLocationPermission() async {
    return await _locationService.requestPermission();
  }
}
