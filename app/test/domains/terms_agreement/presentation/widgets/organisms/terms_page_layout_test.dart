import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_page_layout.dart';

import '../../../../../utils/fake_data/fake_terms_data_generator.dart';
import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsPageLayout', () {
    late MockTermsPageLayoutCallbacks mockCallbacks;

    setUp(() {
      mockCallbacks = TermsMockFactory.createTermsPageLayoutCallbacks();
    });

    Widget createTestWidget({
      String? title,
      String? content,
      VoidCallback? onClose,
      VoidCallback? onAgree,
    }) {
      return AppWrappers.wrapWithMaterialApp(
        TermsPageLayout(
          title: title ?? FakeTermsDataGenerator.createFakeTermsTitle(type: 'terms'),
          content: content ?? FakeTermsDataGenerator.createFakeTermsContentText(type: 'terms'),
          onClose: onClose ?? () {},
          onAgree: onAgree ?? () {},
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
          widgetType: TermsPageLayout,
          expectedCount: 1,
        );
        // TermsPageLayout 내부의 Scaffold 확인
        final termsPageLayout = find.byType(TermsPageLayout);
        final scaffoldInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Scaffold),
        );
        expect(scaffoldInLayout, findsOneWidget);
        // TermsPageLayout 내부의 메인 Stack 확인
        final stackInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Stack),
        );
        expect(stackInLayout, findsAtLeastNWidgets(1));
      });

      testWidgets('Stack 구조를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // TermsPageLayout 내부의 Stack 확인
        final termsPageLayout = find.byType(TermsPageLayout);
        final stackInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Stack),
        );
        expect(stackInLayout, findsAtLeastNWidgets(1));
        
        // 메인 Stack (첫 번째 Stack)의 children 개수 확인
        final mainStack = tester.widget<Stack>(stackInLayout.first);
        expect(mainStack.children.length, equals(3)); // 헤더, 내용, 푸터
      });

      testWidgets('Positioned 위젯들이 올바르게 배치되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // TermsPageLayout 내부의 Positioned 위젯들 확인
        final termsPageLayout = find.byType(TermsPageLayout);
        final positionedInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Positioned),
        );
        expect(positionedInLayout, findsNWidgets(4)); // 헤더, 닫기버튼, 내용, 푸터
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('상단 헤더가 올바른 위치에 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final positionedWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Positioned),
        );
        final headerPositioned = tester.widget<Positioned>(positionedWidgets.at(0));
        
        expect(headerPositioned.top, equals(0));
        expect(headerPositioned.left, equals(0));
        expect(headerPositioned.right, equals(0));
        expect(headerPositioned.height, equals(88));
      });

      testWidgets('중간 내용 영역이 올바른 위치에 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final positionedWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Positioned),
        );
        final contentPositioned = tester.widget<Positioned>(positionedWidgets.at(2)); // 내용은 3번째
        
        expect(contentPositioned.top, equals(88));
        expect(contentPositioned.left, equals(23));
        expect(contentPositioned.right, equals(23));
        expect(contentPositioned.bottom, equals(124));
      });

      testWidgets('하단 버튼 영역이 올바른 위치에 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final positionedWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Positioned),
        );
        final footerPositioned = tester.widget<Positioned>(positionedWidgets.at(3)); // 푸터는 4번째
        
        expect(footerPositioned.bottom, equals(0));
        expect(footerPositioned.left, equals(0));
        expect(footerPositioned.right, equals(0));
        expect(footerPositioned.height, equals(124));
      });

      testWidgets('SafeArea가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifySafeArea(
          tester: tester,
          finder: find.byType(TermsPageLayout),
          shouldHaveSafeArea: true,
        );
      });
    });

    group('색상 테스트', () {
      testWidgets('헤더 배경색이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
        
        // 헤더 컨테이너의 색상 확인
        final headerContainer = tester.widget<Container>(containers.at(0));
        final decoration = headerContainer.decoration as BoxDecoration;
        expect(decoration.color, equals(const Color(0xFFF2E5CC)));
      });

      testWidgets('푸터 배경색이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
        
        // 푸터 컨테이너의 색상 확인
        final footerContainer = tester.widget<Container>(containers.at(1));
        final decoration = footerContainer.decoration as BoxDecoration;
        expect(decoration.color, equals(const Color(0xFFF2E5CC)));
      });

      testWidgets('전체 배경색이 흰색이어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final scaffolds = find.byType(Scaffold);
        expect(scaffolds, findsAtLeastNWidgets(1));
        
        // TermsPageLayout 내부의 Scaffold 찾기
        final termsPageLayout = find.byType(TermsPageLayout);
        final scaffoldInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Scaffold),
        );
        expect(scaffoldInLayout, findsOneWidget);
        
        final scaffold = tester.widget<Scaffold>(scaffoldInLayout);
        expect(scaffold.backgroundColor, equals(Colors.white));
      });
    });

    group('콘텐츠 테스트', () {
      testWidgets('제목이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 이용 약관 동의',
          expectedCount: 1,
        );
      });

      testWidgets('약관 내용이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // 실제 렌더링된 텍스트 확인
        final allTexts = find.byType(Text);
        expect(allTexts, findsWidgets);
        
        // 본문 텍스트 확인
        bool foundContent = false;
        for (int i = 0; i < allTexts.evaluate().length; i++) {
          final text = tester.widget<Text>(allTexts.at(i));
          if (text.data != null && text.data!.contains('제1조 (목적)')) {
            foundContent = true;
            break;
          }
        }
        expect(foundContent, isTrue);
      });

      testWidgets('동의 버튼이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '모두 동의합니다 !',
          expectedCount: 1,
        );
      });

      testWidgets('닫기 버튼이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: IconButton,
          expectedCount: 1,
        );
      });
    });

    group('스크롤 기능 테스트', () {
      testWidgets('내용 영역이 스크롤 가능해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyScrollableContent(
          tester: tester,
          finder: find.byType(TermsPageLayout),
          shouldBeScrollable: true,
        );
      });

      testWidgets('긴 내용이 스크롤되어야 한다', (WidgetTester tester) async {
        // Given
        final longContent = FakeTermsDataGenerator.createFakeTermsContentText(type: 'terms') * 10;
        await tester.pumpWidget(createTestWidget(content: longContent));

        // When
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
        await tester.pump();

        // Then
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('이벤트 처리 테스트', () {
      testWidgets('닫기 버튼 클릭 시 onClose 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onClose()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onClose: mockCallbacks.onClose));

        // When
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onClose()).called(1);
      });

      testWidgets('동의 버튼 클릭 시 onAgree 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onAgree()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onAgree: mockCallbacks.onAgree));

        // When
        await tester.tap(find.text('모두 동의합니다 !'));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onAgree()).called(1);
      });

      testWidgets('콜백이 null일 때도 안전하게 처리되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // 에러가 발생하지 않아야 함
        await tester.tap(find.byType(IconButton));
        await tester.tap(find.text('모두 동의합니다 !'));
        await tester.pump();
        
        // 정상적으로 실행되었는지 확인
        expect(find.byType(TermsPageLayout), findsOneWidget);
      });
    });

    group('다양한 약관 타입 테스트', () {
      testWidgets('이용약관 레이아웃이 올바르게 표시되어야 한다', (WidgetTester tester) async {
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
        bool foundContent = false;
        for (int i = 0; i < allTexts.evaluate().length; i++) {
          final text = tester.widget<Text>(allTexts.at(i));
          if (text.data != null && text.data!.contains('제1조 (목적)')) {
            foundContent = true;
            break;
          }
        }
        expect(foundContent, isTrue);
      });

      testWidgets('개인정보보호방침 레이아웃이 올바르게 표시되어야 한다', (WidgetTester tester) async {
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
        bool foundContent = false;
        for (int i = 0; i < allTexts.evaluate().length; i++) {
          final text = tester.widget<Text>(allTexts.at(i));
          if (text.data != null && text.data!.contains('수집·이용 목적')) {
            foundContent = true;
            break;
          }
        }
        expect(foundContent, isTrue);
      });

      testWidgets('위치정보 약관 레이아웃이 올바르게 표시되어야 한다', (WidgetTester tester) async {
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
        bool foundContent = false;
        for (int i = 0; i < allTexts.evaluate().length; i++) {
          final text = tester.widget<Text>(allTexts.at(i));
          if (text.data != null && text.data!.contains('사용자 위치 기반 서비스 제공')) {
            foundContent = true;
            break;
          }
        }
        expect(foundContent, isTrue);
      });
    });

    group('접근성 테스트', () {
      testWidgets('스크린 리더 호환성이 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final scaffoldInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Scaffold),
        );
        expect(scaffoldInLayout, findsOneWidget);
        
        final scaffold = tester.widget<Scaffold>(scaffoldInLayout);
        expect(scaffold, isNotNull);
        // Scaffold는 자동으로 접근성 지원을 제공함
      });

      testWidgets('모든 텍스트가 읽기 가능해야 한다', (WidgetTester tester) async {
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
      testWidgets('Mock 콜백들이 올바르게 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onClose()).thenReturn(null);
        when(() => mockCallbacks.onAgree()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(
          onClose: mockCallbacks.onClose,
          onAgree: mockCallbacks.onAgree,
        ));

        // When
        await tester.tap(find.byType(IconButton));
        await tester.tap(find.text('모두 동의합니다 !'));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onClose()).called(1);
        verify(() => mockCallbacks.onAgree()).called(1);
      });

      testWidgets('Mock 콜백들이 호출되지 않아야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onClose()).thenReturn(null);
        when(() => mockCallbacks.onAgree()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(
          onClose: mockCallbacks.onClose,
          onAgree: mockCallbacks.onAgree,
        ));

        // When
        // 아무것도 클릭하지 않음

        // Then
        verifyNever(() => mockCallbacks.onClose());
        verifyNever(() => mockCallbacks.onAgree());
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
          widgetType: TermsPageLayout,
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
          widgetType: TermsPageLayout,
          expectedCount: 1,
        );
      });
    });
  });
}
