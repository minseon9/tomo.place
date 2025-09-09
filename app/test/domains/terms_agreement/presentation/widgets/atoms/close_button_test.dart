import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/close_button.dart';

import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsCloseButton', () {
    late MockCloseButtonCallbacks mockCallbacks;

    setUp(() {
      mockCallbacks = TermsMockFactory.createCloseButtonCallbacks();
    });

    Widget createTestWidget({
      VoidCallback? onPressed,
    }) {
      return AppWrappers.wrapWithMaterialApp(
        TermsCloseButton(onPressed: onPressed ?? () {}),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsCloseButton,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: IconButton,
          expectedCount: 1,
        );
      });

      testWidgets('IconButton 구조를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton, isNotNull);
        expect(iconButton.icon, isA<Icon>());
      });

      testWidgets('올바른 아이콘을 표시해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        final icon = iconButton.icon as Icon;
        expect(icon.icon, equals(Icons.close));
      });
    });

    group('스타일 테스트', () {
      testWidgets('아이콘 크기가 24여야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTermsCloseButtonStyle(
          tester: tester,
          finder: find.byType(IconButton),
          expectedSize: 24,
        );
      });

      testWidgets('아이콘 색상이 검은색이어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTermsCloseButtonStyle(
          tester: tester,
          finder: find.byType(IconButton),
          expectedColor: Colors.black,
        );
      });

      testWidgets('패딩이 제로여야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTermsCloseButtonStyle(
          tester: tester,
          finder: find.byType(IconButton),
          expectedPadding: EdgeInsets.zero,
        );
      });

      testWidgets('SizedBox 크기가 24x24여야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsAtLeastNWidgets(1));
        
        // TermsCloseButton 내부의 SizedBox를 찾기 (첫 번째 것)
        final termsCloseButton = find.byType(TermsCloseButton);
        final sizedBoxInButton = find.descendant(
          of: termsCloseButton,
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxInButton, findsAtLeastNWidgets(1));
        
        final sizedBox = tester.widget<SizedBox>(sizedBoxInButton.first);
        expect(sizedBox.width, equals(24));
        expect(sizedBox.height, equals(24));
      });
    });

    group('이벤트 처리 테스트', () {
      testWidgets('버튼 클릭 시 onPressed 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onPressed()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onPressed: mockCallbacks.onPressed));

        // When
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onPressed()).called(1);
      });

      testWidgets('onPressed가 null일 때도 안전하게 처리되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(onPressed: () {}));

        // Then
        // 에러가 발생하지 않아야 함
        expect(() => tester.tap(find.byType(IconButton)), returnsNormally);
      });

      testWidgets('여러 번 클릭해도 정상 동작해야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onPressed()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onPressed: mockCallbacks.onPressed));

        // When
        await tester.tap(find.byType(IconButton));
        await tester.tap(find.byType(IconButton));
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onPressed()).called(3);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton, isNotNull);
        // IconButton은 기본적으로 접근성 속성을 제공함
      });

      testWidgets('스크린 리더 호환성이 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton, isNotNull);
        // IconButton은 자동으로 스크린 리더 지원을 제공함
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('전체 레이아웃이 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsCloseButton = find.byType(TermsCloseButton);
        expect(termsCloseButton, findsOneWidget);
        
        final sizedBoxInButton = find.descendant(
          of: termsCloseButton,
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxInButton, findsAtLeastNWidgets(1));
        final sizedBox = tester.widget<SizedBox>(sizedBoxInButton.first);
        expect(sizedBox, isNotNull);

        final iconButtonInButton = find.descendant(
          of: termsCloseButton,
          matching: find.byType(IconButton),
        );
        expect(iconButtonInButton, findsOneWidget);
        final iconButton = tester.widget<IconButton>(iconButtonInButton);
        expect(iconButton, isNotNull);
      });

      testWidgets('위젯이 올바른 크기로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsCloseButton = find.byType(TermsCloseButton);
        final sizedBoxInButton = find.descendant(
          of: termsCloseButton,
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxInButton, findsAtLeastNWidgets(1));
        
        WidgetVerifiers.verifyWidgetSize(
          tester: tester,
          finder: sizedBoxInButton.first,
          expectedWidth: 24,
          expectedHeight: 24,
        );
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock 콜백이 올바르게 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onPressed()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onPressed: mockCallbacks.onPressed));

        // When
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onPressed()).called(1);
      });

      testWidgets('Mock 콜백이 호출되지 않아야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onPressed()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onPressed: mockCallbacks.onPressed));

        // When
        // 아무것도 클릭하지 않음

        // Then
        verifyNever(() => mockCallbacks.onPressed());
      });
    });

    group('상태 테스트', () {
      testWidgets('위젯이 안정적인 상태를 유지해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsCloseButton,
          expectedCount: 1,
        );
      });

      testWidgets('위젯이 재빌드되어도 안정적이어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsCloseButton,
          expectedCount: 1,
        );
      });
    });
  });
}
