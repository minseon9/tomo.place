import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/shared/ui/design_system/atoms/indicators/divider_line.dart';
import 'package:app/shared/ui/design_system/tokens/colors.dart';
import '../../../../utils/widget_test_utils.dart';

void main() {
  group('DividerLine', () {
    group('렌더링 테스트', () {
      testWidgets('기본 구분선이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(),
          ),
        );

        expect(find.byType(DividerLine), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('커스텀 크기의 구분선이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(
              width: 200.0,
              height: 2.0,
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(200.0));
        expect(container.constraints?.maxHeight, equals(2.0));
      });

      testWidgets('커스텀 색상의 구분선이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(
              color: Colors.red,
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.red));
      });
    });

    group('기본값 테스트', () {
      testWidgets('기본 높이가 1이어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxHeight, equals(1.0));
      });

      testWidgets('기본 너비가 무한대여야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(double.infinity));
      });

      testWidgets('기본 색상이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(DesignTokens.tomoDarkGray.withValues(alpha: 0.3)));
      });
    });

    group('크기 테스트', () {
      testWidgets('커스텀 너비가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(width: 150.0),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(150.0));
      });

      testWidgets('커스텀 높이가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(height: 3.0),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxHeight, equals(3.0));
      });

      testWidgets('너비와 높이가 모두 커스텀으로 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(
              width: 100.0,
              height: 5.0,
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(100.0));
        expect(container.constraints?.maxHeight, equals(5.0));
      });
    });

    group('색상 테스트', () {
      testWidgets('다양한 색상이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
        ];

        for (final color in colors) {
          await tester.pumpWidget(
            WidgetTestUtils.wrapWithMaterialApp(
              DividerLine(color: color),
            ),
          );

          final container = tester.widget<Container>(find.byType(Container));
          final decoration = container.decoration as BoxDecoration;
          expect(decoration.color, equals(color));
        }
      });

      testWidgets('투명도가 있는 색상이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(
              color: Color(0x80000000), // 50% 투명도
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(const Color(0x80000000)));
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('Column 내에서 올바르게 배치되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const Column(
              children: [
                Text('Above'),
                DividerLine(),
                Text('Below'),
              ],
            ),
          ),
        );

        expect(find.text('Above'), findsOneWidget);
        expect(find.byType(DividerLine), findsOneWidget);
        expect(find.text('Below'), findsOneWidget);
      });

      testWidgets('Row 내에서 올바르게 배치되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const Row(
              children: [
                Text('Left'),
                DividerLine(width: 50.0, height: 20.0),
                Text('Right'),
              ],
            ),
          ),
        );

        expect(find.text('Left'), findsOneWidget);
        expect(find.byType(DividerLine), findsOneWidget);
        expect(find.text('Right'), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('구분선이 시각적으로 표시되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.decoration, isNotNull);
        expect(container.decoration, isA<BoxDecoration>());
      });

      testWidgets('커스텀 색상이 시각적으로 구분되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            const DividerLine(color: Colors.blue),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.blue));
      });
    });
  });
}
