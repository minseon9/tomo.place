import 'device_type.dart';

class ResponsiveConfig {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;


  static DeviceType getDeviceType(double width) {
    if (width < mobileBreakpoint) return DeviceType.mobile;

    return DeviceType.tablet;
  }
}
