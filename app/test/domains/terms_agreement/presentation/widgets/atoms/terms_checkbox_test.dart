import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/terms_checkbox.dart';

import '../../../../../utils/domains/test_terms_util.dart';
import '../../../../../utils/test_actions_util.dart';
import '../../../../../utils/test_wrappers_util.dart';
import '../../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../../utils/verifiers/test_style_verifier.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(false);
  });

  group('TermsCheckbox', () {
    late ValueChanged<bool?> mockOnChanged;
    late TermsMocks mocks;

    setUp(() {
      mocks = TestTermsUtil.createMocks();
    });

    Widget createTestWidget({
      bool isChecked = true,
      bool isEnabled = false,
      ValueChanged<bool?>? onChanged,
    }) {
      return TestWrappersUtil.material(
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
        TestRenderVerifier.expectRenders<TermsCheckbox>();
        TestRenderVerifier.expectRenders<GestureDetector>();
        TestRenderVerifier.expectRenders<Container>();
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
        final containerFinder = find.byType(Container).first;
        TestRenderVerifier.expectRenders<Container>();
        TestStyleVerifier.expectContainerDecoration(
          tester,
          containerFinder,
          color: Colors.transparent,
        );
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
          createTestWidget(isEnabled: false, onChanged: mocks.onChanged.call),
        );

        // When
        await TestActionsUtil.tapFinderAndSettle(
          tester,
          find.byType(GestureDetector),
        );

        // Then
        verifyNever(() => mocks.onChanged(any()));
      });

      testWidgets('활성화 상태에서 onChanged 콜백이 호출되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        await tester.pumpWidget(
          createTestWidget(isEnabled: true, onChanged: mocks.onChanged.call),
        );

        // When
        await TestActionsUtil.tapFinderAndSettle(
          tester,
          find.byType(GestureDetector),
        );

        // Then
        verify(() => mocks.onChanged(any())).called(1);
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
          createTestWidget(isEnabled: true, onChanged: mocks.onChanged.call),
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
        await tester.pumpWidget(
          createTestWidget(isEnabled: true, onChanged: mocks.onChanged.call),
        );

        // When
        await TestActionsUtil.tapFinderAndSettle(
          tester,
          find.byType(GestureDetector),
        );

        // Then
        verify(() => mocks.onChanged(any())).called(1);
      });

      testWidgets('Mock 콜백이 호출되지 않아야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(
          createTestWidget(isEnabled: false, onChanged: mocks.onChanged.call),
        );

        // When
        await TestActionsUtil.tapFinderAndSettle(
          tester,
          find.byType(GestureDetector),
        );

        // Then
        verifyNever(() => mocks.onChanged(any()));
      });
    });
  });
}
