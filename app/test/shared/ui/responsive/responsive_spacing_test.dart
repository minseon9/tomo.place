import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_spacing.dart';
import 'package:tomo_place/shared/ui/responsive/device_type.dart';

import '../../../utils/responsive_test_helper.dart';

void main() {
  group('ResponsiveSpacing', () {
    group('getResponsive', () {
      testWidgets('모바일에서 1.0x 스케일링 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const baseSpacing = 16.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('16.0'), findsOneWidget);
      });

      testWidgets('태블릿에서 1.2x 스케일링 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const baseSpacing = 16.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('19.2'), findsOneWidget);
      });

      testWidgets('경계값에서 올바른 스케일링 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.mobileBreakpointSize;
        const baseSpacing = 10.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('12.0'), findsOneWidget);
      });

      testWidgets('0 스페이싱 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const baseSpacing = 0.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('0.0'), findsOneWidget);
      });

      testWidgets('음수 스페이싱 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const baseSpacing = -10.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('-12.0'), findsOneWidget);
      });

      testWidgets('매우 큰 스페이싱 값 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const baseSpacing = 1000.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('1200.0'), findsOneWidget);
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
      testWidgets('모바일 브레이크포인트 직전에서 모바일 스케일링', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.justBelowMobileBreakpoint;
        const baseSpacing = 20.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('20.0'), findsOneWidget);
      });

      testWidgets('모바일 브레이크포인트 직후에서 태블릿 스케일링', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.justAboveMobileBreakpoint;
        const baseSpacing = 20.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('24.0'), findsOneWidget);
      });
    });

    group('랜덤 값 테스트', () {
      testWidgets('랜덤 모바일 크기에서 올바른 스케일링', (WidgetTester tester) async {
        // Given
        final screenSize = ResponsiveTestHelper.createMobileSize();
        final baseSpacing = ResponsiveTestHelper.createRandomDouble(max: 100);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        final expectedResult = baseSpacing * 1.0; // 모바일 multiplier
        expect(find.text('$expectedResult'), findsOneWidget);
      });

      testWidgets('랜덤 태블릿 크기에서 올바른 스케일링', (WidgetTester tester) async {
        // Given
        final screenSize = ResponsiveTestHelper.createTabletSize();
        final baseSpacing = ResponsiveTestHelper.createRandomDouble(max: 100);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSpacing.getResponsive(
                  context,
                  baseSpacing,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        final expectedResult = baseSpacing * 1.2; // 태블릿 multiplier
        expect(find.text('$expectedResult'), findsOneWidget);
      });
    });
  });
}