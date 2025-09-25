import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/entities/location_permission_result.dart';
import '../../core/usecases/check_location_permission_usecase.dart';
import '../../core/usecases/request_location_permission_usecase.dart';
import '../models/location_permission_state.dart';

class LocationPermissionNotifier extends StateNotifier<LocationPermissionState> {
  LocationPermissionNotifier(this._ref) : super(const LocationPermissionInitial()) {
    _setupAppLifecycleObserver();
  }

  final Ref _ref;
  late final _AppLifecycleObserver _lifecycleObserver;
  
  CheckLocationPermissionUseCase get _checkPermission =>
      _ref.read(checkLocationPermissionUseCaseProvider);
  RequestLocationPermissionUseCase get _requestPermission =>
      _ref.read(requestLocationPermissionUseCaseProvider);

  void _setupAppLifecycleObserver() {
    _lifecycleObserver = _AppLifecycleObserver(this);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  Future<void> checkPermission() async {
    state = const LocationPermissionLoading();
    
    try {
      final result = await _checkPermission.execute();
      _updateStateFromResult(result);
    } catch (e) {
      state = const LocationPermissionDenied(
        message: '위치 권한 상태를 확인할 수 없습니다.',
      );
    }
  }

  Future<void> requestPermission() async {
    state = const LocationPermissionLoading();
    
    try {
      final result = await _requestPermission.execute();
      _updateStateFromResult(result);
    } catch (e) {
      state = const LocationPermissionDenied(
        message: '위치 권한 요청에 실패했습니다.',
      );
    }
  }

  Future<void> onAppResumed() async {
    await checkPermission();
  }

  void _updateStateFromResult(LocationPermissionResult result) {
    if (result == state) {
      return;
    }

    if (result.hasLocationPermission) {
      if (result.hasPartialPermission) {
        state = LocationPermissionPartial(message: result.message ?? '');
      } else {
        state = const LocationPermissionGranted();
      }
    } else if (result.canRequestInApp) {
      state = LocationPermissionDenied(
        message: result.message ?? '',
      );
    } else {
      state = LocationPermissionPermanentlyDenied(
        message: result.message ?? '',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final LocationPermissionNotifier _notifier;
  
  _AppLifecycleObserver(this._notifier);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notifier.onAppResumed();
    }
  }
}

final locationPermissionNotifierProvider = StateNotifierProvider<LocationPermissionNotifier, LocationPermissionState>((ref) {
  return LocationPermissionNotifier(ref);
});
