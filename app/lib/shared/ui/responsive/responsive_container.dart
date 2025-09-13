import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'device_type.dart';
import 'responsive_config.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    required this.height,
    this.mobileWidthPercent = 0.75,
    this.tabletWidthPercent = 0.7,
    this.maxWidth,
    this.minWidth,
  });

  final Widget child;

  final double height;
  final double mobileWidthPercent;
  final double tabletWidthPercent;
  final double? maxWidth;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = ResponsiveConfig.getDeviceType(screenSize.width);

    final constrainedWidth = _calculateWidth(screenSize.width, deviceType);

    return Container(width: constrainedWidth, height: height, child: child);
  }

  double _calculateWidth(double screenWidth, DeviceType deviceType) {
    final widthPercent = deviceType == DeviceType.mobile
        ? mobileWidthPercent
        : tabletWidthPercent;

    double calculatedWidth = screenWidth * widthPercent;

    if (maxWidth != null) {
      calculatedWidth = math.min(calculatedWidth, maxWidth!);
    }
    if (minWidth != null) {
      calculatedWidth = math.max(calculatedWidth, minWidth!);
    }

    return calculatedWidth;
  }
}
