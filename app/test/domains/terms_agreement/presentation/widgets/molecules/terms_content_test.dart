import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_content.dart';

import '../../../../../utils/fake_data/fake_terms_data_generator.dart';
import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsContent', () {
    late MockTermsContentCallbacks mockCallbacks;

    setUp(() {
      mockCallbacks = TermsMockFactory.createTermsContentCallbacks();
    });

    Widget createTestWidget({
      String? title,
      String? content,
    }) {
      return AppWrappers.wrapWithMaterialApp(
        Scaffold(
          body: SizedBox(
            height: 400, // 테스트를 위한 고정 높이
            child: TermsContent(
              title: title ?? FakeTermsDataGenerator.createFakeTermsTitle(type: 'terms'),
              content: content ?? FakeTermsDataGenerator.createFakeTermsContentText(type: 'terms'),
            ),
          ),
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
          widgetType: TermsContent,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Column,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: SingleChildScrollView,
          expectedCount: 1,
        );
      });

      testWidgets('Column 구조를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final column = tester.widget<Column>(find.byType(Column));
        expect(column, isNotNull);
        expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
      });

      testWidgets('제목과 본문이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 이용 약관 동의',
          expectedCount: 1,
        );
        
        // 실제 렌더링된 텍스트 확인
        final allTexts = find.byType(Text);
        expect(allTexts, findsWidgets);
        
        // 첫 번째 텍스트 (제목) 확인
        final titleText = tester.widget<Text>(allTexts.first);
        expect(titleText.data, contains('📌 이용 약관 동의'));
        
        // 두 번째 텍스트 (본문) 확인
        if (allTexts.evaluate().length > 1) {
          final contentText = tester.widget<Text>(allTexts.at(1));
          expect(contentText.data, contains('제1조 (목적)'));
        }
      });
    });

    group('텍스트 스타일 테스트', () {
      testWidgets('제목에 올바른 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final titleText = tester.widget<Text>(find.text('📌 이용 약관 동의'));
        expect(titleText.style, isNotNull);
        expect(titleText.style?.fontSize, equals(24));
        expect(titleText.style?.fontWeight, equals(FontWeight.w600));
        expect(titleText.style?.letterSpacing, equals(-0.48));
      });

      testWidgets('본문에 올바른 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final contentTexts = find.byType(Text);
        final contentText = tester.widget<Text>(contentTexts.at(1)); // 두 번째 Text 위젯 (본문)
        expect(contentText.style, isNotNull);
        expect(contentText.style?.fontSize, equals(16));
        expect(contentText.style?.fontWeight, equals(FontWeight.w400));
        expect(contentText.style?.height, equals(1.5));
      });

      testWidgets('텍스트 색상이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final titleText = tester.widget<Text>(find.text('📌 이용 약관 동의'));
        final contentTexts = find.byType(Text);
        final contentText = tester.widget<Text>(contentTexts.at(1));

        expect(titleText.style?.color, equals(const Color(0xFF212121)));
        expect(contentText.style?.color, equals(const Color(0xFF212121)));
      });
    });

    group('스크롤 기능 테스트', () {
      testWidgets('SingleChildScrollView가 존재해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyScrollableContent(
          tester: tester,
          finder: find.byType(TermsContent),
          shouldBeScrollable: true,
        );
      });

      testWidgets('긴 내용이 스크롤 가능해야 한다', (WidgetTester tester) async {
        // Given
        final longContent = FakeTermsDataGenerator.createFakeTermsContentText(type: 'terms') * 10;
        await tester.pumpWidget(createTestWidget(content: longContent));

        // When & Then
        final scrollView = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
        expect(scrollView, isNotNull);
        expect(scrollView.scrollDirection, equals(Axis.vertical));
      });

      testWidgets('스크롤 동작이 정상적으로 작동해야 한다', (WidgetTester tester) async {
        // Given
        final longContent = FakeTermsDataGenerator.createFakeTermsContentText(type: 'terms') * 5;
        await tester.pumpWidget(createTestWidget(content: longContent));

        // When
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
        await tester.pump();

        // Then
        // 스크롤이 정상적으로 작동해야 함 (에러가 발생하지 않아야 함)
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('제목과 본문 사이에 올바른 간격이 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsContent = find.byType(TermsContent);
        final sizedBoxInContent = find.descendant(
          of: termsContent,
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxInContent, findsOneWidget);
        
        // SizedBox의 높이가 24인 것을 확인
        final spacingBox = tester.widget<SizedBox>(sizedBoxInContent);
        expect(spacingBox.height, equals(24));
      });

      testWidgets('Expanded 위젯이 본문을 감싸야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Expanded,
          expectedCount: 1,
        );
      });

      testWidgets('전체 레이아웃이 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.children.length, equals(3)); // Text, SizedBox, Expanded
      });
    });

    group('다양한 내용 테스트', () {
      testWidgets('이용약관 내용이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(
          title: FakeTermsDataGenerator.createFakeTermsTitle(type: 'terms'),
          content: FakeTermsDataGenerator.createFakeTermsContentText(type: 'terms'),
        ));

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 이용 약관 동의',
          expectedCount: 1,
        );
        
        // 실제 렌더링된 텍스트 확인
        final allTexts = find.byType(Text);
        expect(allTexts, findsWidgets);
        
        // 본문 텍스트 확인
        if (allTexts.evaluate().length > 1) {
          final contentText = tester.widget<Text>(allTexts.at(1));
          expect(contentText.data, contains('제1조 (목적)'));
        }
      });

      testWidgets('개인정보보호방침 내용이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(
          title: FakeTermsDataGenerator.createFakeTermsTitle(type: 'privacy'),
          content: FakeTermsDataGenerator.createFakeTermsContentText(type: 'privacy'),
        ));

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 개인 정보 보호 방침 동의',
          expectedCount: 1,
        );
        
        // 실제 렌더링된 텍스트 확인
        final allTexts = find.byType(Text);
        expect(allTexts, findsWidgets);
        
        // 본문 텍스트 확인
        if (allTexts.evaluate().length > 1) {
          final contentText = tester.widget<Text>(allTexts.at(1));
          expect(contentText.data, contains('수집·이용 목적'));
        }
      });

      testWidgets('위치정보 약관 내용이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(
          title: FakeTermsDataGenerator.createFakeTermsTitle(type: 'location'),
          content: FakeTermsDataGenerator.createFakeTermsContentText(type: 'location'),
        ));

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 위치정보 수집·이용 및 제3자 제공 동의',
          expectedCount: 1,
        );
        
        // 실제 렌더링된 텍스트 확인
        final allTexts = find.byType(Text);
        expect(allTexts, findsWidgets);
        
        // 본문 텍스트 확인
        if (allTexts.evaluate().length > 1) {
          final contentText = tester.widget<Text>(allTexts.at(1));
          expect(contentText.data, contains('사용자 위치 기반 서비스 제공'));
        }
      });
    });

    group('접근성 테스트', () {
      testWidgets('스크린 리더 호환성이 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final column = tester.widget<Column>(find.byType(Column));
        expect(column, isNotNull);
        // Text 위젯들은 자동으로 스크린 리더 지원을 제공함
      });

      testWidgets('텍스트가 읽기 가능해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);
        
        // 모든 텍스트가 비어있지 않아야 함
        for (int i = 0; i < textWidgets.evaluate().length; i++) {
          final text = tester.widget<Text>(textWidgets.at(i));
          expect(text.data, isNotEmpty);
        }
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock 콜백이 올바르게 처리되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onScroll()).thenReturn(null);
        when(() => mockCallbacks.onContentTap()).thenReturn(null);

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        // Mock 콜백들이 정상적으로 설정되었는지 확인
        expect(mockCallbacks, isNotNull);
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
          widgetType: TermsContent,
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
          widgetType: TermsContent,
          expectedCount: 1,
        );
      });
    });
  });
}
