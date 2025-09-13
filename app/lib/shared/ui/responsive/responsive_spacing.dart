import 'package:flutter/material.dart';

import 'device_type.dart';
import 'responsive_config.dart';

class ResponsiveSpacing {
  static const Map<DeviceType, double> spacingMultipliers = {
    DeviceType.mobile: 1.0,
    DeviceType.tablet: 1.2,
  };

  static double getResponsive(BuildContext context, double baseSpacing) {
    final deviceType = ResponsiveConfig.getDeviceType(
      MediaQuery.sizeOf(context).width,
    );

    return baseSpacing * spacingMultipliers[deviceType]!;
  }
}
