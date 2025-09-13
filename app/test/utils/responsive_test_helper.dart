import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

import 'package:tomo_place/shared/ui/responsive/device_type.dart';

/// 반응형 테스트를 위한 헬퍼 클래스
/// 
/// 이 클래스는 반응형 기능 자체를 테스트하는 것이 아니라,
/// 반응형 기능을 사용하는 위젯들의 테스트를 위한 유틸리티를 제공합니다.
class ResponsiveTestHelper {
  static final _faker = Faker();

  /// 테스트용 위젯을 생성합니다.
  /// MediaQuery를 통해 화면 크기를 설정할 수 있습니다.
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

  /// 모바일 크기의 화면 사이즈를 생성합니다.
  static Size createMobileSize() {
    return Size(
      _faker.randomGenerator.integer(599, min: 320).toDouble(),
      _faker.randomGenerator.integer(900, min: 600).toDouble(),
    );
  }

  /// 태블릿 크기의 화면 사이즈를 생성합니다.
  static Size createTabletSize() {
    return Size(
      _faker.randomGenerator.integer(2000, min: 600).toDouble(),
      _faker.randomGenerator.integer(1500, min: 800).toDouble(),
    );
  }

  /// 특정 디바이스 타입에 맞는 화면 사이즈를 생성합니다.
  static Size createSizeForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return createMobileSize();
      case DeviceType.tablet:
        return createTabletSize();
    }
  }

  /// 랜덤한 double 값을 생성합니다.
  static double createRandomDouble({double min = 0, double max = 100}) {
    return _faker.randomGenerator.decimal(scale: max - min) + min;
  }

  /// 랜덤한 EdgeInsets를 생성합니다.
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
