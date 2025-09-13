import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_sizing.dart';

import '../../../utils/responsive_test_helper.dart';

void main() {
  group('ResponsiveSizing', () {
    group('getResponsivePadding', () {
      testWidgets('모바일에서 1.0x 패딩 스케일링 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const left = 16.0;
        const top = 8.0;
        const right = 16.0;
        const bottom = 8.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsivePadding(
                  context,
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom,
                );
                return Text('${result.left},${result.top},${result.right},${result.bottom}');
              },
            ),
          ),
        );

        // Then
        expect(find.text('16.0,8.0,16.0,8.0'), findsOneWidget);
      });

      testWidgets('태블릿에서 1.2x 패딩 스케일링 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const left = 16.0;
        const top = 8.0;
        const right = 16.0;
        const bottom = 8.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsivePadding(
                  context,
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom,
                );
                return Text('${result.left},${result.top},${result.right},${result.bottom}');
              },
            ),
          ),
        );

        // Then
        expect(find.text('19.2,9.6,19.2,9.6'), findsOneWidget);
      });

      testWidgets('기본값 0으로 패딩 생성', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsivePadding(context);
                return Text('${result.left},${result.top},${result.right},${result.bottom}');
              },
            ),
          ),
        );

        // Then
        expect(find.text('0.0,0.0,0.0,0.0'), findsOneWidget);
      });

      testWidgets('음수 패딩 값 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const left = -10.0;
        const top = -5.0;
        const right = -10.0;
        const bottom = -5.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsivePadding(
                  context,
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom,
                );
                return Text('${result.left},${result.top},${result.right},${result.bottom}');
              },
            ),
          ),
        );

        // Then
        expect(find.text('-12.0,-6.0,-12.0,-6.0'), findsOneWidget);
      });
    });

    group('getResponsiveHeight', () {
      testWidgets('화면 높이의 50% 반환', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const heightPercent = 0.5;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveHeight(
                  context,
                  heightPercent,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('400.0'), findsOneWidget);
      });

      testWidgets('최소 높이 제한 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const heightPercent = 0.1; // 80px
        const minHeight = 100.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveHeight(
                  context,
                  heightPercent,
                  minHeight: minHeight,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('100.0'), findsOneWidget);
      });

      testWidgets('최대 높이 제한 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const heightPercent = 0.8; // 640px
        const maxHeight = 500.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveHeight(
                  context,
                  heightPercent,
                  maxHeight: maxHeight,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('500.0'), findsOneWidget);
      });

      testWidgets('최소/최대 높이 모두 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const heightPercent = 0.5; // 400px
        const minHeight = 300.0;
        const maxHeight = 500.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveHeight(
                  context,
                  heightPercent,
                  minHeight: minHeight,
                  maxHeight: maxHeight,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('400.0'), findsOneWidget);
      });

      testWidgets('0% 높이 처리', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const heightPercent = 0.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveHeight(
                  context,
                  heightPercent,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('0.0'), findsOneWidget);
      });

      testWidgets('100% 높이 처리', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const heightPercent = 1.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveHeight(
                  context,
                  heightPercent,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('800.0'), findsOneWidget);
      });
    });

    group('getResponsiveWidth', () {
      testWidgets('화면 너비의 50% 반환', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const widthPercent = 0.5;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveWidth(
                  context,
                  widthPercent,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('200.0'), findsOneWidget);
      });

      testWidgets('최소 너비 제한 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const widthPercent = 0.1; // 40px
        const minWidth = 100.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveWidth(
                  context,
                  widthPercent,
                  minWidth: minWidth,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('100.0'), findsOneWidget);
      });

      testWidgets('최대 너비 제한 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const widthPercent = 0.8; // 320px
        const maxWidth = 300.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveWidth(
                  context,
                  widthPercent,
                  maxWidth: maxWidth,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('300.0'), findsOneWidget);
      });

      testWidgets('최소/최대 너비 모두 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(400, 800);
        const widthPercent = 0.5; // 200px
        const minWidth = 150.0;
        const maxWidth = 250.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getResponsiveWidth(
                  context,
                  widthPercent,
                  minWidth: minWidth,
                  maxWidth: maxWidth,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('200.0'), findsOneWidget);
      });
    });

    group('getValueByDevice', () {
      testWidgets('모바일에서 mobile 값 반환', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const mobileValue = 16.0;
        const tabletValue = 20.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('16.0'), findsOneWidget);
      });

      testWidgets('태블릿에서 tablet 값 반환', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const mobileValue = 16.0;
        const tabletValue = 20.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('20.0'), findsOneWidget);
      });

      testWidgets('경계값에서 올바른 값 반환', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.mobileBreakpointSize;
        const mobileValue = 10.0;
        const tabletValue = 15.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('15.0'), findsOneWidget);
      });

      testWidgets('음수 값 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const mobileValue = -5.0;
        const tabletValue = -10.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('-5.0'), findsOneWidget);
      });

      testWidgets('0 값 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const mobileValue = 0.0;
        const tabletValue = 0.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('0.0'), findsOneWidget);
      });
    });

    group('경계값 테스트', () {
      testWidgets('모바일 브레이크포인트 직전에서 모바일 값 반환', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.justBelowMobileBreakpoint;
        const mobileValue = 10.0;
        const tabletValue = 20.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('10.0'), findsOneWidget);
      });

      testWidgets('모바일 브레이크포인트 직후에서 태블릿 값 반환', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.justAboveMobileBreakpoint;
        const mobileValue = 10.0;
        const tabletValue = 20.0;

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('20.0'), findsOneWidget);
      });
    });

    group('랜덤 값 테스트', () {
      testWidgets('랜덤 모바일 크기에서 올바른 값 반환', (WidgetTester tester) async {
        // Given
        final screenSize = ResponsiveTestHelper.createMobileSize();
        final mobileValue = ResponsiveTestHelper.createRandomDouble(max: 100);
        final tabletValue = ResponsiveTestHelper.createRandomDouble(max: 100);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('$mobileValue'), findsOneWidget);
      });

      testWidgets('랜덤 태블릿 크기에서 올바른 값 반환', (WidgetTester tester) async {
        // Given
        final screenSize = ResponsiveTestHelper.createTabletSize();
        final mobileValue = ResponsiveTestHelper.createRandomDouble(max: 100);
        final tabletValue = ResponsiveTestHelper.createRandomDouble(max: 100);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: screenSize,
            child: Builder(
              builder: (context) {
                final result = ResponsiveSizing.getValueByDevice(
                  context,
                  mobile: mobileValue,
                  tablet: tabletValue,
                );
                return Text('$result');
              },
            ),
          ),
        );

        // Then
        expect(find.text('$tabletValue'), findsOneWidget);
      });
    });
  });
}
