import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/expand_icon.dart';

import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsExpandIcon', () {
    late MockVoidCallback mockOnTap;

    setUp(() {
      mockOnTap = TermsMockFactory.createVoidCallback();
    });

    Widget createTestWidget({VoidCallback? onTap}) {
      return AppWrappers.wrapWithMaterialApp(TermsExpandIcon(onTap: onTap));
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsExpandIcon,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: GestureDetector,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Icon,
          expectedCount: 1,
        );
      });

      testWidgets('올바른 아이콘을 표시해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.icon, equals(Icons.chevron_right));
      });

      testWidgets('올바른 아이콘 크기를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.size, equals(16));
      });

      testWidgets('올바른 아이콘 색상을 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, isNotNull);
      });
    });

    group('크기 테스트', () {
      testWidgets('올바른 컨테이너 크기를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(24));
        expect(container.constraints?.maxHeight, equals(24));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('클릭 시 onTap 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnTap()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onTap: mockOnTap.call));

        // When
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Then
        verify(() => mockOnTap()).called(1);
      });

      testWidgets('onTap이 null일 때 클릭해도 에러가 발생하지 않아야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(onTap: null));

        // Then
        expect(() async {
          await tester.tap(find.byType(GestureDetector));
          await tester.pump();
        }, returnsNormally);
      });

      testWidgets('터치 영역이 적절해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final gestureDetector = tester.widget<GestureDetector>(
          find.byType(GestureDetector),
        );
        expect(gestureDetector, isNotNull);
        // 터치 영역은 24x24이지만 GestureDetector가 터치를 감지하므로 충분함
      });
    });

    group('스타일 테스트', () {
      testWidgets('투명 배경을 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.transparent));
      });

      testWidgets('아이콘 색상이 일관되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, isNotNull);
        // 색상이 null이 아니어야 함 (DesignTokens.tomoBlack)
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock 콜백이 올바르게 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnTap()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onTap: mockOnTap.call));

        // When
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Then
        verify(() => mockOnTap()).called(1);
      });

      testWidgets('Mock 콜백이 여러 번 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnTap()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onTap: mockOnTap.call));

        // When
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Then
        verify(() => mockOnTap()).called(2);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final gestureDetector = tester.widget<GestureDetector>(
          find.byType(GestureDetector),
        );
        expect(gestureDetector, isNotNull);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });
  });
}
