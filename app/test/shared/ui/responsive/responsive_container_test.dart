import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/responsive/device_type.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_container.dart';

import '../../../utils/test_responsive_util.dart';
import '../../../utils/test_wrappers_util.dart';
import '../../../utils/verifiers/test_render_verifier.dart';

void main() {
  Future<Size> _pumpAndReadSize(
      WidgetTester tester, {
        required Size screenSize,
        required ResponsiveContainer container,
      }) async {
    await tester.pumpWidget(
      TestWrappersUtil.withScreenSize(
        container,
        screenSize: screenSize,
      ),
    );
    return tester.getSize(find.byWidget(container));
  }

  group('ResponsiveContainer', () {
    group('기본 생성자', () {
      testWidgets('모바일에서 기본 너비 비율 적용', (tester) async {
        const screenSize = TestResponsiveUtil.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.mobile,
          screenSize: screenSize,
          mobilePercent: 0.75,
          tabletPercent: 0.7,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });

      testWidgets('태블릿에서 기본 너비 비율 적용', (tester) async {
        const screenSize = TestResponsiveUtil.standardTabletSize;
        const container = ResponsiveContainer(
          height: 100,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.tablet,
          screenSize: screenSize,
          mobilePercent: 0.75,
          tabletPercent: 0.7,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });

      testWidgets('커스텀 너비 비율 적용', (tester) async {
        const screenSize = TestResponsiveUtil.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.5,
          tabletWidthPercent: 0.6,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.mobile,
          screenSize: screenSize,
          mobilePercent: 0.5,
          tabletPercent: 0.6,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });
    });

    group('최대/최소 너비 제한', () {
      testWidgets('최대 너비 제한 적용', (tester) async {
        const screenSize = TestResponsiveUtil.standardTabletSize;
        const container = ResponsiveContainer(
          height: 100,
          maxWidth: 500,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.tablet,
          screenSize: screenSize,
          mobilePercent: 0.75,
          tabletPercent: 0.7,
          maxWidth: 500,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });

      testWidgets('최소 너비 제한 적용', (tester) async {
        const screenSize = TestResponsiveUtil.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.1,
          minWidth: 100,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.mobile,
          screenSize: screenSize,
          mobilePercent: 0.1,
          tabletPercent: 0.7,
          minWidth: 100,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });

      testWidgets('최대/최소 너비 모두 적용', (tester) async {
        const screenSize = TestResponsiveUtil.standardTabletSize;
        const container = ResponsiveContainer(
          height: 100,
          tabletWidthPercent: 0.8,
          maxWidth: 800,
          minWidth: 600,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.tablet,
          screenSize: screenSize,
          mobilePercent: 0.75,
          tabletPercent: 0.8,
          maxWidth: 800,
          minWidth: 600,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });
    });

    group('경계값 테스트', () {
      testWidgets('모바일 브레이크포인트 직전에서 모바일 너비 비율 적용', (tester) async {
        const screenSize = TestResponsiveUtil.justBelowMobileBreakpoint;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.5,
          tabletWidthPercent: 0.7,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.mobile,
          screenSize: screenSize,
          mobilePercent: 0.5,
          tabletPercent: 0.7,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });

      testWidgets('모바일 브레이크포인트 직후에서 태블릿 너비 비율 적용', (tester) async {
        const screenSize = TestResponsiveUtil.justAboveMobileBreakpoint;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.5,
          tabletWidthPercent: 0.7,
          child: Text('Test'),
        );

        final size = await _pumpAndReadSize(
          tester,
          screenSize: screenSize,
          container: container,
        );

        final expected = TestResponsiveUtil.expectedWidth(
          deviceType: DeviceType.tablet,
          screenSize: screenSize,
          mobilePercent: 0.5,
          tabletPercent: 0.7,
        );
        expect(size.width, expected);
        expect(size.height, 100);
      });
    });

    group('렌더링', () {
      testWidgets('자식 위젯이 올바르게 렌더링되는지 확인', (tester) async {
        const screenSize = TestResponsiveUtil.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          child: Text('Test Child'),
        );

        await tester.pumpWidget(
          TestWrappersUtil.withScreenSize(
            container,
            screenSize: screenSize,
          ),
        );

        TestRenderVerifier.expectText('Test Child');
      });

      testWidgets('키가 올바르게 전달되는지 확인', (tester) async {
        const key = Key('test-key');
        const container = ResponsiveContainer(
          key: key,
          height: 100,
          child: Text('Test'),
        );

        await tester.pumpWidget(
          TestWrappersUtil.withScreenSize(
            container,
            screenSize: TestResponsiveUtil.standardMobileSize,
          ),
        );

        expect(find.byKey(key), findsOneWidget);
      });
    });
  });
}
