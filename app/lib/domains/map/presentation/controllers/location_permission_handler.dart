import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_permission_state.dart';
import '../widgets/molecules/location_permission_presenter.dart';
import 'location_permission_notifier.dart';

class LocationPermissionHandler {
  final Ref _ref;

  LocationPermissionHandler(this._ref);

  LocationPermissionNotifier get _locationPermissionNotifier =>
      _ref.read(locationPermissionNotifierProvider.notifier);
  LocationPermissionPresenter get _locationPermissionPresenter =>
      _ref.read(locationPermissionPresenterProvider);

  void handleOnAppStart(BuildContext context, LocationPermissionState state) {
    switch (state) {
      case LocationPermissionLoading():
        break;
      case LocationPermissionDenied():
        _requestPermission();
        break;
      case LocationPermissionPermanentlyDenied():
        _locationPermissionPresenter.showSettingsModal(context);
        break;
      case LocationPermissionPartial():
        _locationPermissionPresenter.showToast(context, state.message);
        break;
      default:
        break;
    }
  }

  void handleOnResume(BuildContext context, LocationPermissionState state) {
    switch (state) {
      case LocationPermissionDenied():
      case LocationPermissionPermanentlyDenied():
        _locationPermissionPresenter.showToast(context, '위치 권한이 없어 일부 서비스 사용이 불가능합니다.');
        break;
      case LocationPermissionPartial():
        _locationPermissionPresenter.showToast(context, '위치가 정확하지 않을 수 있습니다.');
        break;
      default:
        break;
    }
  }

  void handleOnAction(BuildContext context, LocationPermissionState state) {
    switch (state) {
      case LocationPermissionDenied():
        _requestPermission();
        break;
      case LocationPermissionPermanentlyDenied():
        _locationPermissionPresenter.showSettingsModal(context);
        break;
      default:
        break;
    }
  }

  void _requestPermission() {
    _locationPermissionNotifier.requestPermission();
  }
}

final locationPermissionHandlerProvider = Provider<LocationPermissionHandler>((ref) {
  return LocationPermissionHandler(ref);
});
