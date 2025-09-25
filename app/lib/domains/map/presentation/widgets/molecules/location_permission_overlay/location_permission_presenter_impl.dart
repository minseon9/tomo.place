import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/domains/map/presentation/widgets/molecules/location_permission_overlay/permission_settings_modal.dart';
import 'package:tomo_place/shared/ui/components/toast_widget.dart';

import '../location_permission_presenter.dart';

class LocationPermissionPresenterImpl implements LocationPermissionPresenter {
  final Ref ref;

  LocationPermissionPresenterImpl(this.ref);

  @override
  void showSettingsModal(BuildContext context) {
    PermissionSettingsModal.showSettingsModal(context);
  }

  @override
  void showToast(BuildContext context, String message) {
    AppToast.show(context, message);
  }
}
