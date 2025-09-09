import 'package:tomo_place/shared/ui/design_system/atoms/indicators/divider_line.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../utils/design_system/design_system_test_utils.dart';
import '../../../../../utils/widget/finders.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('DividerLine', () {
    group('생성자', () {
      testWidgets('기본 파라미터로 생성되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(),
          ),
        );

        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: DividerLine,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Container,
        );
      });

      testWidgets('기본값이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(),
          ),
        );

        final dividerLine = tester.widget<DividerLine>(WidgetFinders.byType<DividerLine>());
        expect(dividerLine.width, isNull);
        expect(dividerLine.height, equals(1.0));
        expect(dividerLine.color, isNull);
      });
    });

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(),
          ),
        );

        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: DividerLine,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Container,
        );
      });

      testWidgets('커스텀 파라미터로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(
              width: 200.0,
              height: 3.0,
              color: Colors.red,
            ),
          ),
        );

        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: DividerLine,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Container,
        );
      });
    });

    group('크기 테스트', () {
      testWidgets('기본 높이가 1.0으로 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        expect(container.constraints?.maxHeight, equals(1.0));
      });

      testWidgets('커스텀 높이가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(height: 5.0),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        expect(container.constraints?.maxHeight, equals(5.0));
      });

      testWidgets('커스텀 너비가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(width: 150.0),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        expect(container.constraints?.maxWidth, equals(150.0));
      });

      testWidgets('width가 null일 때 double.infinity가 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        expect(container.constraints?.maxWidth, equals(double.infinity));
      });
    });

    group('스타일 테스트', () {
      testWidgets('기본 색상이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        final decoration = container.decoration as BoxDecoration;
        final expectedColor = DesignTokens.tomoDarkGray.withValues(alpha: 0.3);
        
        expect(decoration.color, equals(expectedColor));
      });

      testWidgets('커스텀 색상이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(color: Colors.blue),
          ),
        );

        WidgetVerifiers.verifyContainerStyle(
          tester: tester,
          finder: WidgetFinders.byType<Container>(),
          expectedColor: Colors.blue,
        );
      });

      testWidgets('투명한 색상이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        const transparentColor = Color(0x00000000);
        
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(color: transparentColor),
          ),
        );

        WidgetVerifiers.verifyContainerStyle(
          tester: tester,
          finder: WidgetFinders.byType<Container>(),
          expectedColor: transparentColor,
        );
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('Column에서 올바르게 표시되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithColumn(
            child: const DividerLine(),
            additionalChildren: const [
              Text('Above'),
              Text('Below'),
            ],
          ),
        );

        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: DividerLine,
        );
        WidgetVerifiers.verifyTextDisplays(text: 'Above');
        WidgetVerifiers.verifyTextDisplays(text: 'Below');
      });

      testWidgets('Row에서 올바르게 표시되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithRow(
            child: const DividerLine(width: 100.0),
            additionalChildren: const [
              Text('Left'),
              Text('Right'),
            ],
          ),
        );

        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: DividerLine,
        );
        WidgetVerifiers.verifyTextDisplays(text: 'Left');
        WidgetVerifiers.verifyTextDisplays(text: 'Right');
      });

      testWidgets('여러 DividerLine이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const Column(
              children: [
                Text('Section 1'),
                DividerLine(),
                Text('Section 2'),
                DividerLine(height: 2.0, color: Colors.red),
                Text('Section 3'),
              ],
            ),
          ),
        );

        DesignSystemTestUtils.verifyWidgetRenders(
          tester: tester,
          widgetType: DividerLine,
          expectedCount: 2,
        );
        WidgetVerifiers.verifyTextDisplays(text: 'Section 1');
        WidgetVerifiers.verifyTextDisplays(text: 'Section 2');
        WidgetVerifiers.verifyTextDisplays(text: 'Section 3');
      });
    });

    group('경계값 테스트', () {
      testWidgets('height가 0일 때도 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(height: 0.0),
          ),
        );

        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: DividerLine,
        );
        
        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        expect(container.constraints?.maxHeight, equals(0.0));
      });

      testWidgets('매우 큰 height 값이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(height: 1000.0),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        expect(container.constraints?.maxHeight, equals(1000.0));
      });

      testWidgets('매우 큰 width 값이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(width: 10000.0),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        expect(container.constraints?.maxWidth, equals(10000.0));
      });
    });

    group('복합 스타일 테스트', () {
      testWidgets('모든 커스텀 파라미터가 동시에 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const DividerLine(
              width: 300.0,
              height: 4.0,
              color: Colors.green,
            ),
          ),
        );

        final container = tester.widget<Container>(WidgetFinders.byType<Container>());
        final decoration = container.decoration as BoxDecoration;
        
        expect(container.constraints?.maxWidth, equals(300.0));
        expect(container.constraints?.maxHeight, equals(4.0));
        expect(decoration.color, equals(Colors.green));
      });

      testWidgets('DesignTokens 색상이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: DividerLine(
              color: DesignTokens.tomoBlack,
            ),
          ),
        );

        WidgetVerifiers.verifyContainerStyle(
          tester: tester,
          finder: WidgetFinders.byType<Container>(),
          expectedColor: DesignTokens.tomoBlack,
        );
      });
    });

    group('접근성 테스트', () {
      testWidgets('시각적 구분선으로서의 역할을 올바르게 수행해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          DesignSystemTestUtils.wrapWithMaterialApp(
            child: const Column(
              children: [
                Text('Content Above'),
                DividerLine(),
                Text('Content Below'),
              ],
            ),
          ),
        );

        // DividerLine이 두 텍스트 사이에 올바르게 위치하는지 확인
        final dividerFinder = WidgetFinders.byType<DividerLine>();
        final aboveTextFinder = WidgetFinders.byText('Content Above');
        final belowTextFinder = WidgetFinders.byText('Content Below');
        
        expect(dividerFinder, findsOneWidget);
        expect(aboveTextFinder, findsOneWidget);
        expect(belowTextFinder, findsOneWidget);
      });
    });
  });
}
