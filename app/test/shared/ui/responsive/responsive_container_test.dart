import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_container.dart';

import '../../../utils/responsive_test_helper.dart';

void main() {
  group('ResponsiveContainer', () {
    Widget createTestWidget({
      required Size screenSize,
      required ResponsiveContainer container,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: Scaffold(body: container),
        ),
      );
    }

    group('기본 생성자', () {
      testWidgets('모바일에서 기본 너비 비율 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(281.25)); // 375 * 0.75
        expect(size.height, equals(100));
      });

      testWidgets('태블릿에서 기본 너비 비율 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const container = ResponsiveContainer(
          height: 100,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(716.8)); // 1024 * 0.7
        expect(size.height, equals(100));
      });

      testWidgets('커스텀 너비 비율 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.5,
          tabletWidthPercent: 0.6,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(187.5)); // 375 * 0.5
        expect(size.height, equals(100));
      });
    });

    group('최대/최소 너비 제한', () {
      testWidgets('최대 너비 제한 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const container = ResponsiveContainer(
          height: 100,
          maxWidth: 500,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(500)); // maxWidth로 제한됨
        expect(size.height, equals(100));
      });

      testWidgets('최소 너비 제한 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.1, // 37.5px
          minWidth: 100,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(100)); // minWidth로 제한됨
        expect(size.height, equals(100));
      });

      testWidgets('최대/최소 너비 모두 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const container = ResponsiveContainer(
          height: 100,
          tabletWidthPercent: 0.8, // 819.2px
          maxWidth: 800,
          minWidth: 600,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(800)); // maxWidth로 제한됨
        expect(size.height, equals(100));
      });

      testWidgets('계산된 너비가 최소/최대 범위 내에 있을 때', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const container = ResponsiveContainer(
          height: 100,
          tabletWidthPercent: 0.5, // 512px
          maxWidth: 800,
          minWidth: 400,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(512)); // 계산된 값 그대로
        expect(size.height, equals(100));
      });
    });

    group('경계값 테스트', () {
      testWidgets('모바일 브레이크포인트 직전에서 모바일 너비 비율 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.justBelowMobileBreakpoint;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.5,
          tabletWidthPercent: 0.7,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(299.5)); // 599 * 0.5
        expect(size.height, equals(100));
      });

      testWidgets('모바일 브레이크포인트 직후에서 태블릿 너비 비율 적용', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.justAboveMobileBreakpoint;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.5,
          tabletWidthPercent: 0.7,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(420.7)); // 601 * 0.7
        expect(size.height, equals(100));
      });
    });

    group('자식 위젯 렌더링', () {
      testWidgets('자식 위젯이 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          child: Text('Test Child'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        expect(find.text('Test Child'), findsOneWidget);
      });

      testWidgets('복잡한 자식 위젯 렌더링', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardTabletSize;
        const container = ResponsiveContainer(
          height: 200,
          child: Column(
            children: [
              Text('Title'),
              Text('Subtitle'),
              Icon(Icons.star),
            ],
          ),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });
    });

    group('키 전달', () {
      testWidgets('키가 올바르게 전달되는지 확인', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const key = Key('test-key');
        const container = ResponsiveContainer(
          key: key,
          height: 100,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        expect(find.byKey(key), findsOneWidget);
      });
    });

    group('랜덤 값 테스트', () {
      testWidgets('랜덤 모바일 크기에서 올바른 너비 계산', (WidgetTester tester) async {
        // Given
        final screenSize = ResponsiveTestHelper.createMobileSize();
        final mobileWidthPercent = ResponsiveTestHelper.createRandomDouble(min: 0.1, max: 0.9);
        final tabletWidthPercent = ResponsiveTestHelper.createRandomDouble(min: 0.1, max: 0.9);
        final height = ResponsiveTestHelper.createRandomDouble(min: 50, max: 500);

        final container = ResponsiveContainer(
          height: height,
          mobileWidthPercent: mobileWidthPercent,
          tabletWidthPercent: tabletWidthPercent,
          child: const Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        // 실제 위젯이 화면 크기에 제한받을 수 있으므로 범위로 검증
        expect(size.width, lessThanOrEqualTo(screenSize.width));
        expect(size.width, greaterThan(0));
        expect(size.height, equals(height));
      });

      testWidgets('랜덤 태블릿 크기에서 올바른 너비 계산', (WidgetTester tester) async {
        // Given
        final screenSize = ResponsiveTestHelper.createTabletSize();
        final mobileWidthPercent = ResponsiveTestHelper.createRandomDouble(min: 0.1, max: 0.9);
        final tabletWidthPercent = ResponsiveTestHelper.createRandomDouble(min: 0.1, max: 0.9);
        final height = ResponsiveTestHelper.createRandomDouble(min: 50, max: 500);

        final container = ResponsiveContainer(
          height: height,
          mobileWidthPercent: mobileWidthPercent,
          tabletWidthPercent: tabletWidthPercent,
          child: const Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        // 실제 위젯이 화면 크기에 제한받을 수 있으므로 범위로 검증
        expect(size.width, lessThanOrEqualTo(screenSize.width));
        expect(size.width, greaterThan(0));
        expect(size.height, equals(height));
      });
    });

    group('극값 테스트', () {
      testWidgets('0% 너비 비율 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 0.0,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(0.0));
        expect(size.height, equals(100));
      });

      testWidgets('100% 너비 비율 처리', (WidgetTester tester) async {
        // Given
        const screenSize = ResponsiveTestHelper.standardMobileSize;
        const container = ResponsiveContainer(
          height: 100,
          mobileWidthPercent: 1.0,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        expect(size.width, equals(375.0)); // 전체 너비
        expect(size.height, equals(100));
      });

      testWidgets('매우 큰 화면에서 최대 너비 제한', (WidgetTester tester) async {
        // Given
        const screenSize = Size(2000, 1000);
        const container = ResponsiveContainer(
          height: 100,
          tabletWidthPercent: 0.8, // 1600px
          maxWidth: 1200,
          child: Text('Test'),
        );

        await tester.pumpWidget(createTestWidget(
          screenSize: screenSize,
          container: container,
        ));

        // Then
        final containerFinder = find.byType(ResponsiveContainer);
        final size = tester.getSize(containerFinder);
        // 위젯이 실제로는 Scaffold 등에 의해 제한될 수 있음
        expect(size.width, lessThanOrEqualTo(1200)); // maxWidth 이하
        expect(size.width, greaterThan(0));
        expect(size.height, equals(100));
      });
    });
  });
}
