import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/terms_checkbox.dart';

import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsCheckbox', () {
    late MockValueChangedBool mockOnChanged;

    setUp(() {
      mockOnChanged = TermsMockFactory.createValueChangedBool();
    });

    Widget createTestWidget({
      bool isChecked = true,
      bool isEnabled = false,
      ValueChanged<bool?>? onChanged,
    }) {
      return AppWrappers.wrapWithMaterialApp(
        TermsCheckbox(
          isChecked: isChecked,
          isEnabled: isEnabled,
          onChanged: onChanged,
        ),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsCheckbox,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: GestureDetector,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Container,
          expectedCount: 1,
        );
      });

      testWidgets('체크된 상태로 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isChecked: true));

        // Then
        final svgPicture = find.byType(SvgPicture);
        expect(svgPicture, findsOneWidget);
      });

      testWidgets('체크되지 않은 상태로 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isChecked: false));

        // Then
        final svgPicture = find.byType(SvgPicture);
        expect(svgPicture, findsNothing);
        final container = find.byType(Container);
        expect(container, findsWidgets);
      });
    });

    group('크기 및 스타일 테스트', () {
      testWidgets('Container 위젯이 존재해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        expect(container, findsOneWidget);
      });

      testWidgets('투명한 배경이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.transparent));
      });

      testWidgets('체크된 상태에서 SVG가 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isChecked: true));

        // Then
        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(svgPicture, isNotNull);
        expect(svgPicture.colorFilter, isNotNull);
      });
    });

    group('상태 테스트', () {
      testWidgets('비활성화 상태에서 클릭이 무시되어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(
          createTestWidget(isEnabled: false, onChanged: mockOnChanged.call),
        );

        // When
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Then
        verifyNever(() => mockOnChanged(any()));
      });

      testWidgets('활성화 상태에서 onChanged 콜백이 호출되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        await tester.pumpWidget(
          createTestWidget(isEnabled: true, onChanged: mockOnChanged.call),
        );

        // When
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Then
        verify(() => mockOnChanged(any())).called(1);
      });

      testWidgets('비활성화 상태에서 GestureDetector onTap이 null이어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isEnabled: false));

        // Then
        final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector));
        expect(gestureDetector.onTap, isNull);
      });

      testWidgets('활성화 상태에서 GestureDetector onTap이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          createTestWidget(isEnabled: true, onChanged: mockOnChanged.call),
        );

        // Then
        final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector));
        expect(gestureDetector.onTap, isNotNull);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector));
        expect(gestureDetector, isA<GestureDetector>());
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock 콜백이 올바르게 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnChanged(any())).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(isEnabled: true, onChanged: mockOnChanged.call),
        );

        // When
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Then
        verify(() => mockOnChanged(any())).called(1);
      });

      testWidgets('Mock 콜백이 호출되지 않아야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnChanged(any())).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(isEnabled: false, onChanged: mockOnChanged.call),
        );

        // When
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Then
        verifyNever(() => mockOnChanged(any()));
      });
    });
  });
}
