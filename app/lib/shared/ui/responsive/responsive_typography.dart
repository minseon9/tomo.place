import 'package:flutter/material.dart';

import '../design_system/tokens/typography.dart';
import 'device_type.dart';
import 'responsive_config.dart';

class ResponsiveTypography {
  static const Map<DeviceType, double> fontSizeMultipliers = {
    DeviceType.mobile: 1.0,
    DeviceType.tablet: 1.1,
  };

  static TextStyle getResponsiveTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final deviceType = ResponsiveConfig.getDeviceType(
      MediaQuery.sizeOf(context).width,
    );
    final multiplier = fontSizeMultipliers[deviceType]!;

    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * multiplier,
    );
  }

  static TextStyle getResponsiveHeader1(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.header1);

  static TextStyle getResponsiveHeader2(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.header2);

  static TextStyle getResponsiveHeader3(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.header3);

  static TextStyle getResponsiveHead3(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.head3);

  static TextStyle getResponsiveBody(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.body);

  static TextStyle getResponsiveButton(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.button);

  static TextStyle getResponsiveCaption(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.caption);

  static TextStyle getResponsiveBold(BuildContext context) =>
      getResponsiveTextStyle(context, AppTypography.bold);
}
