import 'package:app/shared/ui/design_system/atoms/buttons/base_button.dart';
import 'package:app/shared/ui/design_system/tokens/radius.dart';
import 'package:app/shared/ui/design_system/tokens/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/widget_test_utils.dart';

void main() {
  group('BaseButton', () {
    group('렌더링 테스트', () {
      testWidgets('기본 버튼이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // ignore: unused_local_variable
        bool buttonPressed = false;

        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () => buttonPressed = true,
              child: const Text('Test Button'),
            ),
          ),
        );

        expect(find.byType(BaseButton), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('커스텀 스타일이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              borderColor: Colors.red,
              borderRadius: 10.0,
              height: 60.0,
              width: 200.0,
              child: const Text('Styled Button'),
            ),
          ),
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final buttonStyle = elevatedButton.style;

        expect(buttonStyle?.backgroundColor?.resolve({}), equals(Colors.blue));
        expect(buttonStyle?.foregroundColor?.resolve({}), equals(Colors.white));
        expect(buttonStyle?.side?.resolve({})?.color, equals(Colors.red));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('버튼 탭 시 onPressed 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // ignore: unused_local_variable
        bool buttonPressed = false;

        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () => buttonPressed = true,
              child: const Text('Press Me'),
            ),
          ),
        );

        await WidgetTestActions.tap(tester, find.text('Press Me'));
        expect(buttonPressed, isTrue);
      });

      testWidgets('비활성화된 버튼은 탭해도 콜백이 호출되지 않아야 한다', (WidgetTester tester) async {
        // ignore: unused_local_variable
        bool buttonPressed = false;

        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () => buttonPressed = true,
              isDisabled: true,
              child: const Text('Disabled Button'),
            ),
          ),
        );

        await WidgetTestActions.tap(tester, find.text('Disabled Button'));
        expect(buttonPressed, isFalse);
      });

      testWidgets('로딩 중인 버튼은 탭해도 콜백이 호출되지 않아야 한다', (WidgetTester tester) async {
        // ignore: unused_local_variable
        bool buttonPressed = false;

        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () => buttonPressed = true,
              isLoading: true,
              child: const Text('Loading Button'),
            ),
          ),
        );

        await WidgetTestActions.tap(tester, find.byType(ElevatedButton));
        expect(buttonPressed, isFalse);
      });
    });

    group('로딩 상태 테스트', () {
      testWidgets('로딩 중일 때 CircularProgressIndicator가 표시되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              isLoading: true,
              child: const Text('Loading Button'),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading Button'), findsNothing);
      });

      testWidgets('로딩 중이 아닐 때 child가 표시되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              isLoading: false,
              child: const Text('Normal Button'),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Normal Button'), findsOneWidget);
      });

      testWidgets('로딩 인디케이터가 올바른 크기를 가져야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              isLoading: true,
              child: const Text('Loading Button'),
            ),
          ),
        );

        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        expect(progressIndicator.strokeWidth, equals(2.0));
      });
    });

    group('크기 테스트', () {
      testWidgets('기본 높이가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(onPressed: () {}, child: const Text('Test Button')),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, equals(52.0));
      });

      testWidgets('커스텀 높이가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              height: 60.0,
              child: const Text('Test Button'),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, equals(60.0));
      });

      testWidgets('커스텀 너비가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              width: 200.0,
              child: const Text('Test Button'),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, equals(200.0));
      });
    });

    group('스타일 테스트', () {
      testWidgets('기본 border radius가 올바르게 설정되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(onPressed: () {}, child: const Text('Test Button')),
          ),
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final buttonStyle = elevatedButton.style;
        final shape = buttonStyle?.shape as RoundedRectangleBorder?;

        expect(
          shape?.borderRadius,
          equals(BorderRadius.circular(AppRadius.button)),
        );
      });

      testWidgets('기본 패딩이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(onPressed: () {}, child: const Text('Test Button')),
          ),
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final buttonStyle = elevatedButton.style;

        expect(
          buttonStyle?.padding?.resolve({}),
          equals(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        );
      });

      testWidgets('커스텀 패딩이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(20.0);

        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              padding: customPadding,
              child: const Text('Test Button'),
            ),
          ),
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final buttonStyle = elevatedButton.style;

        expect(buttonStyle?.padding?.resolve({}), equals(customPadding));
      });

      testWidgets('테두리가 있는 버튼이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              borderColor: Colors.blue,
              child: const Text('Bordered Button'),
            ),
          ),
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final buttonStyle = elevatedButton.style;
        final shape = buttonStyle?.shape as RoundedRectangleBorder?;

        expect(shape?.side.color, equals(Colors.blue));
        expect(shape?.side.width, equals(1.0));
      });

      testWidgets('테두리가 없는 버튼이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(onPressed: () {}, child: const Text('No Border Button')),
          ),
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final buttonStyle = elevatedButton.style;
        final shape = buttonStyle?.shape as RoundedRectangleBorder?;

        expect(shape?.side, equals(BorderSide.none));
      });
    });

    group('접근성 테스트', () {
      testWidgets('버튼이 접근 가능해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              child: const Text('Accessible Button'),
            ),
          ),
        );

        expect(find.text('Accessible Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('비활성화된 버튼도 접근 가능해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.wrapWithMaterialApp(
            BaseButton(
              onPressed: () {},
              isDisabled: true,
              child: const Text('Disabled Button'),
            ),
          ),
        );

        expect(find.text('Disabled Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });
  });
}
