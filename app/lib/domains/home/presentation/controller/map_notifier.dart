import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../../../shared/exception_handler/exception_notifier.dart';
import '../../../../shared/exception_handler/exceptions/unknown_exception.dart';
import '../../../../shared/exception_handler/models/exception_interface.dart';
import '../models/map_state.dart';

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._ref) : super(const MapState());

  final Ref _ref;
  final Location _location = Location();
  
  // 서울 경복궁 좌표 (fallback 위치)
  static const LatLng _defaultPosition = LatLng(37.579617, 126.977041);

  ExceptionNotifier get _effects => _ref.read(exceptionNotifierProvider.notifier);

  Future<void> initializeMap() async {
    if (state.isInitialized) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final hasPermission = await _requestLocationPermission();
      
      if (!hasPermission) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          currentPosition: _defaultPosition,
        );
        return;
      }

      final locationData = await _getCurrentLocation();
      final position = locationData != null 
          ? LatLng(locationData.latitude!, locationData.longitude!)
          : _defaultPosition;

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        currentPosition: position,
      );
    } catch (e) {
      final err = _toError(e);
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        currentPosition: _defaultPosition,
      );
      _effects.report(err);
    }
  }

  void setMapController(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
  }

  Future<void> moveToCurrentLocation() async {
    if (state.mapController == null) return;

    try {
      // 이미 현재 위치가 있으면 그것을 사용
      if (state.currentPosition != null) {
        await state.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(state.currentPosition!, 16.0),
        );
        return;
      }

      // 현재 위치가 없으면 새로 가져오기
      final locationData = await _getCurrentLocation();
      if (locationData != null) {
        final newPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        await state.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16.0),
        );

        state = state.copyWith(currentPosition: newPosition);
      } else {
        // 위치를 가져올 수 없으면 기본 위치로 이동
        await state.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_defaultPosition, 16.0),
        );
      }
    } catch (e) {
      final err = _toError(e);
      _effects.report(err);
    }
  }

  Future<bool> _requestLocationPermission() async {
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

  Future<LocationData?> _getCurrentLocation() async {
    try {
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 10,
      );
      
      return await _location.getLocation().timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      return null;
    }
  }

  ExceptionInterface _toError(dynamic e) {
    if (e is ExceptionInterface) {
      return e;
    } else {
      return UnknownException(message: e.toString());
    }
  }

  @override
  void dispose() {
    state.mapController?.dispose();
    super.dispose();
  }
}

// Provider
final mapNotifierProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(ref);
});