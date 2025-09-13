import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tomo_place/shared/ui/design_system/tokens/typography.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_typography.dart';

import '../../../utils/responsive_test_helper.dart';

void main() {
  group('ResponsiveTypography', () {

    group('getResponsiveTextStyle', () {
      testWidgets('모바일에서 1.0x 스케일링 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812); // 모바일 크기
        const baseStyle = AppTypography.button; // fontSize: 14

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveTextStyle(context, baseStyle);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('14.0'), findsOneWidget);
      });

      testWidgets('태블릿에서 1.1x 스케일링 적용', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768); // 태블릿 크기
        const baseStyle = AppTypography.button; // fontSize: 14

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveTextStyle(context, baseStyle);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('15.400000000000002'), findsOneWidget); // 14 * 1.1
      });

      testWidgets('null fontSize 처리', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);
        const baseStyle = TextStyle(fontWeight: FontWeight.bold); // fontSize: null

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveTextStyle(context, baseStyle);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('16.0'), findsOneWidget); // 16 * 1.0 (기본값 16, 모바일)
      });

      testWidgets('기존 스타일 속성 보존', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);
        const baseStyle = AppTypography.button; // fontWeight: FontWeight.w500

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveTextStyle(context, baseStyle);
              return Text('${result.fontWeight}');
            },
          ),
        ));

        // Then
        expect(find.text('FontWeight.w500'), findsOneWidget);
      });
    });

    group('개별 typography 메서드들', () {
      testWidgets('getResponsiveHeader1 - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHeader1(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('32.0'), findsOneWidget);
      });

      testWidgets('getResponsiveHeader1 - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHeader1(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('35.2'), findsOneWidget);
      });

      testWidgets('getResponsiveHeader2 - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHeader2(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('24.0'), findsOneWidget);
      });

      testWidgets('getResponsiveHeader2 - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHeader2(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('26.400000000000002'), findsOneWidget);
      });

      testWidgets('getResponsiveHeader3 - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHeader3(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('20.0'), findsOneWidget);
      });

      testWidgets('getResponsiveHeader3 - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHeader3(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('22.0'), findsOneWidget);
      });

      testWidgets('getResponsiveHead3 - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHead3(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('18.0'), findsOneWidget);
      });

      testWidgets('getResponsiveHead3 - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveHead3(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('19.8'), findsOneWidget);
      });

      testWidgets('getResponsiveBody - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveBody(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('16.0'), findsOneWidget);
      });

      testWidgets('getResponsiveBody - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveBody(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('17.6'), findsOneWidget);
      });

      testWidgets('getResponsiveButton - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveButton(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('14.0'), findsOneWidget);
      });

      testWidgets('getResponsiveButton - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveButton(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('15.400000000000002'), findsOneWidget);
      });

      testWidgets('getResponsiveCaption - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveCaption(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('12.0'), findsOneWidget);
      });

      testWidgets('getResponsiveCaption - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveCaption(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('13.200000000000001'), findsOneWidget);
      });

      testWidgets('getResponsiveBold - 모바일', (WidgetTester tester) async {
        // Given
        const screenSize = Size(375, 812);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveBold(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('12.0'), findsOneWidget);
      });

      testWidgets('getResponsiveBold - 태블릿', (WidgetTester tester) async {
        // Given
        const screenSize = Size(1024, 768);

        await tester.pumpWidget(ResponsiveTestHelper.createTestWidget(
          screenSize: screenSize,
          child: Builder(
            builder: (context) {
              final result = ResponsiveTypography.getResponsiveBold(context);
              return Text('${result.fontSize}');
            },
          ),
        ));

        // Then
        expect(find.text('13.200000000000001'), findsOneWidget);
      });
    });
  });
}
