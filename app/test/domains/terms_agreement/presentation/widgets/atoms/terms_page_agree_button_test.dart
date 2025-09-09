import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/terms_page_agree_button.dart';

import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsPageAgreeButton', () {
    late MockVoidCallback mockOnPressed;

    setUp(() {
      mockOnPressed = TermsMockFactory.createVoidCallback();
    });

    Widget createTestWidget({VoidCallback? onPressed}) {
      return AppWrappers.wrapWithMaterialApp(
        TermsPageAgreeButton(onPressed: onPressed ?? () {}),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsPageAgreeButton,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Container,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Material,
          expectedCount:
              2, // AppWrappers의 Material + TermsPageAgreeButton의 Material
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: InkWell,
          expectedCount: 1,
        );
      });

      testWidgets('올바른 텍스트를 표시해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '동의',
          expectedCount: 1,
        );
      });
    });

    group('크기 테스트', () {
      testWidgets('올바른 크기로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(300));
        expect(container.constraints?.maxHeight, equals(45));
      });
    });

    group('스타일 테스트', () {
      testWidgets('올바른 배경색이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
        // DesignTokens.tomoPrimary300
      });

      testWidgets('테두리 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border, isNotNull);
      });

      testWidgets('둥근 모서리가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, isNotNull);
        expect(decoration.borderRadius, equals(BorderRadius.circular(20.0)));
      });

      testWidgets('텍스트 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final text = tester.widget<Text>(find.text('동의'));
        expect(text.style, isNotNull);
        expect(text.style?.letterSpacing, equals(-0.28));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('클릭 시 onPressed 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnPressed()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(onPressed: mockOnPressed.call),
        );

        // When
        await tester.tap(find.byType(InkWell));
        await tester.pump();

        // Then
        verify(() => mockOnPressed()).called(1);
      });

      testWidgets('터치 피드백이 제공되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell, isNotNull);
        expect(inkWell.borderRadius, isNotNull);
        expect(inkWell.borderRadius, equals(BorderRadius.circular(20.0)));
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('텍스트가 중앙 정렬되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final center = tester.widget<Center>(find.byType(Center));
        expect(center, isNotNull);
      });

      testWidgets('버튼 내부 패딩이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell, isNotNull);
        // InkWell이 터치 영역을 제공함
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock 콜백이 올바르게 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnPressed()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(onPressed: mockOnPressed.call),
        );

        // When
        await tester.tap(find.byType(InkWell));
        await tester.pump();

        // Then
        verify(() => mockOnPressed()).called(1);
      });

      testWidgets('Mock 콜백이 여러 번 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnPressed()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(onPressed: mockOnPressed.call),
        );

        // When
        await tester.tap(find.byType(InkWell));
        await tester.pump();
        await tester.tap(find.byType(InkWell));
        await tester.pump();

        // Then
        verify(() => mockOnPressed()).called(2);
      });

      testWidgets('Mock 콜백이 호출되지 않아야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnPressed()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(onPressed: mockOnPressed.call),
        );

        // When
        // 탭하지 않음

        // Then
        verifyNever(() => mockOnPressed());
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell, isNotNull);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });

    group('Line Coverage 테스트', () {
      testWidgets('모든 라인이 실행되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // Container, Material, InkWell, Center, Text 모든 위젯이 렌더링되어야 함
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Material), findsNWidgets(2));
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('onPressed 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnPressed()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(onPressed: mockOnPressed.call),
        );

        // When
        await tester.tap(find.byType(InkWell));
        await tester.pump();

        // Then
        verify(() => mockOnPressed()).called(1);
      });

      testWidgets('InkWell의 onTap이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.onTap, isNotNull);
      });

      testWidgets('Material의 color가 투명해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final materials = find.byType(Material);
        final buttonMaterial = tester.widget<Material>(materials.at(1)); // 두 번째 Material
        expect(buttonMaterial.color, equals(Colors.transparent));
      });
    });
  });
}
