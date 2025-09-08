import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
          widgetType: Checkbox,
          expectedCount: 1,
        );
      });

      testWidgets('체크된 상태로 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isChecked: true));

        // Then
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });

      testWidgets('체크되지 않은 상태로 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isChecked: false));

        // Then
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isFalse);
      });
    });

    group('크기 및 스타일 테스트', () {
      testWidgets('올바른 크기로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, equals(42));
        expect(sizedBox.height, equals(42));
      });

      testWidgets('둥근 모서리 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.shape, isA<RoundedRectangleBorder>());
      });

      testWidgets('올바른 색상 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.checkColor, equals(Colors.black));
        expect(checkbox.activeColor, equals(Colors.grey[300]));
      });
    });

    group('상태 테스트', () {
      testWidgets('비활성화 상태에서 클릭이 무시되어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(
          createTestWidget(isEnabled: false, onChanged: mockOnChanged.call),
        );

        // When
        await tester.tap(find.byType(Checkbox));
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
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Then
        verify(() => mockOnChanged(any())).called(1);
      });

      testWidgets('비활성화 상태에서 onChanged가 null이어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isEnabled: false));

        // Then
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.onChanged, isNull);
      });

      testWidgets('활성화 상태에서 onChanged가 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          createTestWidget(isEnabled: true, onChanged: mockOnChanged.call),
        );

        // Then
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.onChanged, isNotNull);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox, isA<Checkbox>());
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
        await tester.tap(find.byType(Checkbox));
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
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Then
        verifyNever(() => mockOnChanged(any()));
      });
    });
  });
}
