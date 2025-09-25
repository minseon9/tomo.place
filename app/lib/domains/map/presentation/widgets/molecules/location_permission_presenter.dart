import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_permission_overlay/location_permission_presenter_impl.dart';

abstract class LocationPermissionPresenter {
  void showSettingsModal(
      BuildContext context
  );

  void showToast(
      BuildContext context,
      String message,
      );
}

final locationPermissionPresenterProvider = Provider<LocationPermissionPresenter>((ref) {
  return LocationPermissionPresenterImpl(ref);
});
