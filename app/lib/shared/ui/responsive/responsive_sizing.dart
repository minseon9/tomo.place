import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_config.dart';

import 'device_type.dart';

class ResponsiveSizing {
  static const Map<DeviceType, double> _paddingMultipliers = {
    DeviceType.mobile: 1.0,
    DeviceType.tablet: 1.2,
  };

  static EdgeInsets getResponsiveEdge(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    final deviceType = ResponsiveConfig.getDeviceType(
      MediaQuery.sizeOf(context).width,
    );

    final padding = _paddingMultipliers[deviceType]!;
    return EdgeInsets.fromLTRB(
      left * padding,
      top * padding,
      right * padding,
      bottom * padding,
    );
  }

  static EdgeInsets getResponsiveSymmetricEdge(
      BuildContext context, {
        double vertical = 0,
        double horizontal = 0,
      }) {
    final deviceType = ResponsiveConfig.getDeviceType(
      MediaQuery.sizeOf(context).width,
    );

    final padding = _paddingMultipliers[deviceType]!;
    return EdgeInsets.symmetric(
      vertical: vertical * padding,
      horizontal: horizontal * padding,
    );
  }


  static double getResponsiveHeight(
    BuildContext context,
    double heightPercent, {
    double? minHeight,
    double? maxHeight,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return _getResponsiveValue(
      screenHeight,
      heightPercent,
      minHeight,
      maxHeight,
    );
  }

  static double getResponsiveWidth(
    BuildContext context,
    double widthPercent, {
    double? minWidth,
    double? maxWidth,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return _getResponsiveValue(screenWidth, widthPercent, minWidth, maxWidth);
  }

  static double getValueByDevice(
    BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    final deviceType = ResponsiveConfig.getDeviceType(
      MediaQuery.sizeOf(context).width,
    );

    return deviceType == DeviceType.mobile ? mobile : tablet;
  }

  static double _getResponsiveValue(
    double screenSize,
    double percent,
    double? min,
    double? max,
  ) {
    final calculatedValue = screenSize * percent;

    double finalValue = calculatedValue;
    if (min != null) finalValue = math.max(finalValue, min);
    if (max != null) finalValue = math.min(finalValue, max);

    return finalValue;
  }
}
