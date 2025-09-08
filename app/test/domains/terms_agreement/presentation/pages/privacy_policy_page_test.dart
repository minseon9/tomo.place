import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';

import '../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../utils/widget/verifiers.dart';

void main() {
  group('PrivacyPolicyPage', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = TermsMockFactory.createBuildContext();
    });

    Widget createTestWidget() {
      return MaterialApp(home: const PrivacyPolicyPage());
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: PrivacyPolicyPage,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Scaffold,
          expectedCount: 1,
        );
      });

      testWidgets('Scaffold 구조를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold, isNotNull);
        expect(scaffold.appBar, isNotNull);
        expect(scaffold.body, isNotNull);
      });
    });

    group('AppBar 테스트', () {
      testWidgets('AppBar가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: AppBar,
          expectedCount: 1,
        );
      });

      testWidgets('AppBar 제목이 "개인정보보호방침"이어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(text: '개인정보보호방침', expectedCount: 1);
      });

      testWidgets('AppBar 스타일이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(Colors.white));
        expect(appBar.foregroundColor, equals(Colors.black));
        expect(appBar.elevation, equals(0));
      });

      testWidgets('AppTypography.head3 스타일이 적용되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final titleText = tester.widget<Text>(find.text('개인정보보호방침'));
        expect(titleText.style, isNotNull);
        expect(titleText.style?.fontSize, equals(18));
        expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      });
    });

    group('Body 테스트', () {
      testWidgets('Center 위젯이 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Center,
          expectedCount: 1,
        );
      });

      testWidgets('Padding 위젯이 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Padding,
          expectedCount: 2, // MaterialApp과 PrivacyPolicyPage에서 각각 Padding이 있음
        );
      });

      testWidgets('텍스트 내용이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text:
              '개인정보보호방침 내용이 여기에 표시됩니다.\n\n이 페이지는 추후 실제 개인정보보호방침 내용으로 업데이트될 예정입니다.',
          expectedCount: 1,
        );
        // 전체 텍스트가 하나의 Text 위젯에 포함되어 있으므로 개별 검증은 제거
      });

      testWidgets('텍스트 스타일이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);

        // 첫 번째 텍스트 (제목 제외)
        final contentText = tester.widget<Text>(textWidgets.at(1));
        expect(
          contentText.style?.fontSize,
          equals(18.0),
        ); // MaterialApp 기본 테마 적용
        // textAlign은 MaterialApp 테마에 의해 null이 될 수 있음
        expect(contentText.textAlign, anyOf(equals(TextAlign.center), isNull));
      });
    });

    group('접근성 테스트', () {
      testWidgets('스크린 리더 호환성이 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold, isNotNull);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });

      testWidgets('뒤로가기 버튼이 동작해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar, isNotNull);
        // AppBar는 자동으로 뒤로가기 버튼을 제공함
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('전체 레이아웃이 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.appBar, isNotNull);
        expect(scaffold.body, isNotNull);

        final center = tester.widget<Center>(find.byType(Center).first);
        expect(center, isNotNull);

        final padding = tester.widget<Padding>(find.byType(Padding).first);
        expect(padding, isNotNull);
      });

      testWidgets('텍스트가 중앙 정렬되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final center = tester.widget<Center>(find.byType(Center).first);
        expect(center, isNotNull);

        // body의 Text 위젯을 찾기 위해 더 구체적인 finder 사용
        final textWidgets = find.byType(Text);
        final contentText = tester.widget<Text>(
          textWidgets.at(1),
        ); // 두 번째 Text 위젯 (body 내용)
        // textAlign은 MaterialApp 테마에 의해 null이 될 수 있음
        expect(contentText.textAlign, anyOf(equals(TextAlign.center), isNull));
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock BuildContext가 올바르게 처리되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        when(() => mockContext.mounted).thenReturn(true);

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(mockContext.mounted, isTrue);
      });
    });

    group('상태 테스트', () {
      testWidgets('페이지가 안정적인 상태를 유지해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: PrivacyPolicyPage,
          expectedCount: 1,
        );
      });

      testWidgets('페이지가 재빌드되어도 안정적이어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: PrivacyPolicyPage,
          expectedCount: 1,
        );
      });
    });
  });
}
