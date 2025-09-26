import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

import 'package:tomo_place/shared/ui/responsive/device_type.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_spacing.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_typography.dart';

class TestResponsiveUtil {
  static final _faker = Faker();

  static Widget createTestWidget({
    required Size screenSize,
    required Widget child,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: Scaffold(body: child),
      ),
    );
  }

  static double expectedFontSize(
    double? baseFontSize,
    DeviceType deviceType,
  ) {
    final base = baseFontSize ?? 16;
    final multiplier = ResponsiveTypography.fontSizeMultipliers[deviceType]!;
    return base * multiplier;
  }

  static double expectedWidth({
    required DeviceType deviceType,
    required Size screenSize,
    required double mobilePercent,
    required double tabletPercent,
    double? minWidth,
    double? maxWidth,
  }) {
    final percent = deviceType == DeviceType.mobile ? mobilePercent : tabletPercent;
    final rawWidth = screenSize.width * percent;
    double result = rawWidth;
    if (minWidth != null) result = result < minWidth ? minWidth : result;
    if (maxWidth != null) result = result > maxWidth ? maxWidth : result;
    return result;
  }

  static double expectedSpace({
    required DeviceType deviceType,
    required double baseSpacing,
    required Size screenSize
  }) {
    final multiplier = ResponsiveSpacing.spacingMultipliers[deviceType]!;

    return baseSpacing * multiplier;
  }

  static Size createMobileSize() {
    return Size(
      _faker.randomGenerator.integer(599, min: 320).toDouble(),
      _faker.randomGenerator.integer(900, min: 600).toDouble(),
    );
  }

  static Size createTabletSize() {
    return Size(
      _faker.randomGenerator.integer(2000, min: 600).toDouble(),
      _faker.randomGenerator.integer(1500, min: 800).toDouble(),
    );
  }

  static Size createSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return createMobileSize();
      case DeviceType.tablet:
        return createTabletSize();
    }
  }

  static double createRandomDouble({double min = 0, double max = 100}) {
    return _faker.randomGenerator.decimal(scale: max - min) + min;
  }

  static EdgeInsets createRandomEdgeInsets() {
    return EdgeInsets.fromLTRB(
      createRandomDouble(max: 50),
      createRandomDouble(max: 50),
      createRandomDouble(max: 50),
      createRandomDouble(max: 50),
    );
  }

  /// 랜덤한 TextStyle을 생성합니다.
  static TextStyle createRandomTextStyle() {
    return TextStyle(
      fontSize: createRandomDouble(min: 8, max: 48),
      fontWeight: _faker.randomGenerator.element([
        FontWeight.w100,
        FontWeight.w200,
        FontWeight.w300,
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
        FontWeight.w800,
        FontWeight.w900,
      ]),
    );
  }

  /// 테스트에서 사용할 수 있는 표준 모바일 크기입니다.
  static const Size standardMobileSize = Size(375, 812);

  /// 테스트에서 사용할 수 있는 표준 태블릿 크기입니다.
  static const Size standardTabletSize = Size(1024, 768);

  /// 경계값 테스트를 위한 크기들입니다.
  static const Size mobileBreakpointSize = Size(600, 800);
  static const Size tabletBreakpointSize = Size(1024, 768);
  static const Size justBelowMobileBreakpoint = Size(599, 800);
  static const Size justAboveMobileBreakpoint = Size(601, 800);
  static const Size justBelowTabletBreakpoint = Size(1023, 800);
  static const Size justAboveTabletBreakpoint = Size(1025, 800);
}
