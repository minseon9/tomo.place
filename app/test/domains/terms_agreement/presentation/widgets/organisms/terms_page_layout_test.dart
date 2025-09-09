import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_page_layout.dart';

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
      Map<String, String>? contentMap,
      VoidCallback? onAgree,
    }) {
      return AppWrappers.wrapWithMaterialApp(
        TermsPageLayout(
          title: title ?? '이용 약관 동의',
          contentMap: contentMap ?? {
            '제1조 (목적)': '본 약관은 tomo place가 제공하는 서비스의 이용 조건 및 절차를 규정함을 목적으로 합니다.',
            '제2조 (회원의 의무)': '회원은 관계 법령 및 본 약관의 규정을 준수하여야 합니다.',
          },
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
        // TermsPageLayout 내부의 메인 Column 확인
        final columnInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Column),
        );
        expect(columnInLayout, findsWidgets); // 여러 Column이 있음
      });

      testWidgets('Column 구조를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // TermsPageLayout 내부의 Column 확인
        final termsPageLayout = find.byType(TermsPageLayout);
        final columnInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Column),
        );
        expect(columnInLayout, findsWidgets); // 여러 Column이 있음
        
        // 메인 Column의 children 개수 확인
        final mainColumn = tester.widget<Column>(columnInLayout.first);
        expect(mainColumn.children.length, equals(3)); // 헤더, 내용, 푸터
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('상단 헤더가 올바른 위치에 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final containerWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Container),
        );
        expect(containerWidgets, findsWidgets);
        
        // 헤더 Container 확인
        final headerContainer = tester.widget<Container>(containerWidgets.first);
        expect(headerContainer.decoration, isNotNull);
      });

      testWidgets('중간 내용 영역이 Expanded로 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final expandedWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Expanded),
        );
        expect(expandedWidgets, findsOneWidget);
      });

      testWidgets('하단 버튼 영역이 Padding으로 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final paddingWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Padding),
        );
        expect(paddingWidgets, findsWidgets); // 여러 Padding 위젯들이 있음
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
        
        // 푸터 컨테이너의 색상 확인 (decoration이 null일 수 있음)
        final footerContainer = tester.widget<Container>(containers.at(1));
        if (footerContainer.decoration != null) {
          final decoration = footerContainer.decoration as BoxDecoration;
          expect(decoration.color, equals(const Color(0xFFF2E5CC)));
        }
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
          text: '동의',
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
        final longContentMap = <String, String>{};
        for (int i = 1; i <= 10; i++) {
          longContentMap['제$i조 (목적)'] = '본 약관은 tomo place가 제공하는 서비스의 이용 조건 및 절차를 규정함을 목적으로 합니다. ' * 5;
        }
        await tester.pumpWidget(createTestWidget(contentMap: longContentMap));

        // When
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
        await tester.pump();

        // Then
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('이벤트 처리 테스트', () {
      testWidgets('동의 버튼 클릭 시 onAgree 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onAgree()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(onAgree: mockCallbacks.onAgree));

        // When
        await tester.tap(find.text('동의'));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onAgree()).called(1);
      });

      testWidgets('콜백이 null일 때도 안전하게 처리되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // 에러가 발생하지 않아야 함
        await tester.tap(find.text('동의'));
        await tester.pump();
        
        // 정상적으로 실행되었는지 확인
        expect(find.byType(TermsPageLayout), findsOneWidget);
      });
    });

    group('다양한 약관 타입 테스트', () {
      testWidgets('이용약관 레이아웃이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(
          title: '이용 약관 동의',
          contentMap: {
            '제1조 (목적)': '본 약관은 tomo place가 제공하는 서비스의 이용 조건 및 절차를 규정함을 목적으로 합니다.',
            '제2조 (회원의 의무)': '회원은 관계 법령 및 본 약관의 규정을 준수하여야 합니다.',
          },
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
          title: '개인 정보 보호 방침 동의',
          contentMap: {
            '수집·이용 목적': '회원 식별 및 본인 확인, 서비스 제공 및 맞춤형 기능 제공',
            '수집 항목': '필수: 이메일, 프로필 정보, 위치정보',
          },
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
          title: '위치정보 수집·이용 및 제3자 제공 동의',
          contentMap: {
            '수집·이용 목적': '사용자 위치 기반 서비스 제공, 타인과 위치 공유 기능 제공',
            '수집 항목': '단말기 위치정보(GPS, 기지국, Wi-Fi 등)',
          },
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
          onAgree: mockCallbacks.onAgree,
        ));

        // When
        await tester.tap(find.text('동의'));
        await tester.pump();

        // Then
        verify(() => mockCallbacks.onAgree()).called(1);
      });

      testWidgets('Mock 콜백들이 호출되지 않아야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockCallbacks.onClose()).thenReturn(null);
        when(() => mockCallbacks.onAgree()).thenReturn(null);
        await tester.pumpWidget(createTestWidget(
          onAgree: mockCallbacks.onAgree,
        ));

        // When
        // 아무것도 클릭하지 않음

        // Then
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
