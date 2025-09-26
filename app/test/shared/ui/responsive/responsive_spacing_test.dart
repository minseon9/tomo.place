import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/responsive/device_type.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_spacing.dart';

import '../../../utils/test_responsive_util.dart';
import '../../../utils/test_wrappers_util.dart';

void main() {
  group('ResponsiveSpacing', () {
    group('getResponsive', () {
      testWidgets('모바일에서 1.0x 스케일링 적용', (tester) async {
        const baseSpacing = 16.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseSpacing: baseSpacing,
        );

        final expected = TestResponsiveUtil.expectedSpace(
          deviceType: DeviceType.mobile,
          baseSpacing: baseSpacing,
          screenSize: TestResponsiveUtil.standardMobileSize,
        );
        expect(result, expected);
      });

      testWidgets('태블릿에서 1.2x 스케일링 적용', (tester) async {
        const baseSpacing = 16.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseSpacing: baseSpacing,
        );

        final expected = TestResponsiveUtil.expectedSpace(
          deviceType: DeviceType.tablet,
          baseSpacing: baseSpacing,
          screenSize: TestResponsiveUtil.standardTabletSize,
        );
        expect(result, expected);

      });

      testWidgets('경계값에서 올바른 스케일링 적용', (tester) async {
        const baseSpacing = 10.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.mobileBreakpointSize,
          baseSpacing: baseSpacing,
        );

        final expected = TestResponsiveUtil.expectedSpace(
          deviceType: DeviceType.mobile,
          baseSpacing: baseSpacing,
          screenSize: TestResponsiveUtil.mobileBreakpointSize,
        );
        expect(result, expected);
      });

      testWidgets('0 스페이싱 처리', (tester) async {
        const baseSpacing = 0.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseSpacing: baseSpacing,
        );

        expect(result, 0.0);
      });

      testWidgets('음수 스페이싱 처리', (tester) async {
        const baseSpacing = -10.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseSpacing: baseSpacing,
        );

        final expected = TestResponsiveUtil.expectedSpace(
          deviceType: DeviceType.mobile,
          baseSpacing: baseSpacing,
          screenSize: TestResponsiveUtil.standardTabletSize,
        );
        expect(result, expected);
      });

      testWidgets('매우 큰 스페이싱 값 처리', (tester) async {
        const baseSpacing = 1000.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseSpacing: baseSpacing,
        );

        final expected = TestResponsiveUtil.expectedSpace(
          deviceType: DeviceType.mobile,
          baseSpacing: baseSpacing,
          screenSize: TestResponsiveUtil.standardTabletSize,
        );
        expect(result, expected);
      });
    });

    group('spacingMultipliers 상수', () {
      test('mobile multiplier가 1.0인지 확인', () {
        expect(
          ResponsiveSpacing.spacingMultipliers[DeviceType.mobile],
          equals(1.0),
        );
      });

      test('tablet multiplier가 1.2인지 확인', () {
        expect(
          ResponsiveSpacing.spacingMultipliers[DeviceType.tablet],
          equals(1.2),
        );
      });

      test('모든 디바이스 타입에 대한 multiplier가 정의되어 있는지 확인', () {
        for (final deviceType in DeviceType.values) {
          expect(
            ResponsiveSpacing.spacingMultipliers.containsKey(deviceType),
            isTrue,
            reason: 'DeviceType.$deviceType에 대한 multiplier가 정의되어 있지 않습니다.',
          );
        }
      });
    });

    group('경계값 테스트', () {
      testWidgets('모바일 브레이크포인트 직전에서 모바일 스케일링', (tester) async {
        const baseSpacing = 20.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.justBelowMobileBreakpoint,
          baseSpacing: baseSpacing,
        );

        final expected = TestResponsiveUtil.expectedSpace(
          deviceType: DeviceType.mobile,
          baseSpacing: baseSpacing,
          screenSize: TestResponsiveUtil.justBelowMobileBreakpoint,
        );
        expect(result, expected);
      });

      testWidgets('모바일 브레이크포인트 직후에서 태블릿 스케일링', (tester) async {
        const baseSpacing = 20.0;
        final result = await _readSpacing(
          tester,
          screenSize: TestResponsiveUtil.justAboveMobileBreakpoint,
          baseSpacing: baseSpacing,
        );

        final expected = TestResponsiveUtil.expectedSpace(
          deviceType: DeviceType.mobile,
          baseSpacing: baseSpacing,
          screenSize: TestResponsiveUtil.justAboveMobileBreakpoint,
        );
        expect(result, expected);
      });
    });
  });
}

Future<double> _readSpacing(
    WidgetTester tester, {
      required Size screenSize,
      required double baseSpacing,
    }) async {
  double? value;
  await tester.pumpWidget(
    TestWrappersUtil.withScreenSize(
      Builder(
        builder: (context) {
          value = ResponsiveSpacing.getResponsive(context, baseSpacing);
          return const SizedBox();
        },
      ),
      screenSize: screenSize,
    ),
  );
  return value!;
}
