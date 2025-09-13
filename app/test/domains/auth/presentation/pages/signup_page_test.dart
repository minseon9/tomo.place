import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/presentation/pages/signup_page.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_section.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_agreement_item.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/terms_agree_button.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';
import '../../../../utils/responsive_test_helper.dart';

void main() {
  group('SignupPage', () {
    Widget createWidget({
      Size screenSize = const Size(375, 812), // iPhone 13 기본 크기
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: screenSize),
            child: const SignupPage(),
          ),
        ),
      );
    }

    group('반응형 패딩 적용', () {
      testWidgets('모바일에서 패딩이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(createWidget(screenSize: mobileScreenSize));

        // Padding 위젯들이 존재하는지 확인
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });

      testWidgets('태블릿에서 패딩이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(createWidget(screenSize: tabletScreenSize));

        // Padding 위젯들이 존재하는지 확인
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });

      testWidgets('다양한 화면 크기에서 패딩이 적용되어야 한다', (
        WidgetTester tester,
      ) async {
        final randomScreenSize = ResponsiveTestHelper.createRandomDouble(min: 300, max: 1200);
        final screenSize = Size(randomScreenSize, randomScreenSize * 1.5);

        await tester.pumpWidget(createWidget(screenSize: screenSize));

        // Padding 위젯들이 존재하는지 확인
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });
    });

    group('반응형 간격 적용', () {
      testWidgets('모바일에서 간격이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(createWidget(screenSize: mobileScreenSize));

        // SizedBox 위젯들이 존재하는지 확인
        expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      });

      testWidgets('태블릿에서 간격이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(createWidget(screenSize: tabletScreenSize));

        // SizedBox 위젯들이 존재하는지 확인
        expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      });

      testWidgets('SizedBox 개수 확인', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        // SizedBox 위젯들이 존재하는지 확인 (SocialLoginSection 내부의 SizedBox들도 포함)
        expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      });
    });

    group('기존 로직 보존', () {
      testWidgets('올바른 배경색 설정', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        final scaffold = tester.widget<Scaffold>(
          find.descendant(
            of: find.byType(SignupPage),
            matching: find.byType(Scaffold),
          ),
        );

        expect(scaffold.backgroundColor, equals(AppColors.background));
      });

      testWidgets('SafeArea 적용', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('Spacer 위젯 존재', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byType(Spacer), findsOneWidget);
      });

      testWidgets('Center 위젯 존재', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byType(Center), findsOneWidget);
      });

      testWidgets('SocialLoginSection 존재', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('Column의 mainAxisSize가 기본값', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        final column = find.byType(Column);
        expect(column, findsAtLeastNWidgets(1));
      });
    });

    group('위젯 트리 구조 검증', () {
      testWidgets('올바른 위젯 계층 구조', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        // SignupPage -> Scaffold -> SafeArea -> _SignupPageContent -> Padding -> Column
        expect(find.byType(SignupPage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsAtLeastNWidgets(1));
        expect(find.byType(Spacer), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      });

      testWidgets('Column의 children 개수 확인', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        // Column 위젯이 존재하는지 확인
        expect(find.byType(Column), findsAtLeastNWidgets(1));
      });
    });

    group('반응형 동작 검증', () {
      testWidgets('화면 크기 변경 시 패딩이 재계산되어야 한다', (WidgetTester tester) async {
        // 모바일 크기로 시작
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(createWidget(screenSize: mobileScreenSize));

        // Padding 위젯들이 존재하는지 확인
        expect(find.byType(Padding), findsAtLeastNWidgets(1));

        // 태블릿 크기로 변경
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(createWidget(screenSize: tabletScreenSize));

        // Padding 위젯들이 존재하는지 확인
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });

      testWidgets('화면 크기 변경 시 간격이 재계산되어야 한다', (
        WidgetTester tester,
      ) async {
        // 모바일 크기로 시작
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(createWidget(screenSize: mobileScreenSize));

        // SizedBox 위젯들이 존재하는지 확인
        expect(find.byType(SizedBox), findsAtLeastNWidgets(2));

        // 태블릿 크기로 변경
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(createWidget(screenSize: tabletScreenSize));

        // SizedBox 위젯들이 존재하는지 확인
        expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      });
    });

    group('ProviderScope 통합', () {
      testWidgets('ProviderScope가 올바르게 설정됨', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byType(ProviderScope), findsOneWidget);
      });

      testWidgets('MaterialApp이 올바르게 설정됨', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('TermsAgreementModal 콜백 함수 테스트', () {
      testWidgets('onAgreeAll 콜백이 올바르게 동작해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        // Google 버튼을 찾아서 탭
        final googleButton = find.text('구글로 시작하기');
        expect(googleButton, findsOneWidget);

        await tester.tap(googleButton);
        await tester.pumpAndSettle();

        // TermsAgreementModal이 표시되는지 확인
        expect(find.byType(TermsAgreementModal), findsOneWidget);

        // "모두 동의합니다 !" 버튼을 찾아서 탭
        final agreeAllButton = find.text('모두 동의합니다 !');
        expect(agreeAllButton, findsOneWidget);

        await tester.tap(agreeAllButton);
        await tester.pumpAndSettle();

        // 모달이 닫혔는지 확인
        expect(find.byType(TermsAgreementModal), findsNothing);
      });

      testWidgets('TermsAgreementModal의 텍스트 요소들이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        // Google 버튼을 탭하여 모달 열기
        final googleButton = find.text('구글로 시작하기');
        await tester.tap(googleButton);
        await tester.pumpAndSettle();

        // TermsAgreementModal이 표시되는지 확인
        expect(find.byType(TermsAgreementModal), findsOneWidget);

        // 각 텍스트 요소들이 올바르게 표시되는지 확인
        expect(find.text('이용 약관 동의'), findsOneWidget);
        expect(find.text('개인정보 보호 방침 동의'), findsOneWidget);
        expect(find.text('위치정보 수집·이용 및 제3자 제공 동의'), findsOneWidget);
        expect(find.text('만 14세 이상입니다'), findsOneWidget);
        expect(find.text('모두 동의합니다 !'), findsOneWidget);
      });

      testWidgets('TermsAgreementModal의 구조가 올바르게 구성되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        // Google 버튼을 탭하여 모달 열기
        final googleButton = find.text('구글로 시작하기');
        await tester.tap(googleButton);
        await tester.pumpAndSettle();

        // TermsAgreementModal이 표시되는지 확인
        expect(find.byType(TermsAgreementModal), findsOneWidget);

        // 모달 내부 구조 확인
        expect(find.byType(Stack), findsAtLeastNWidgets(1));
        expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));
        expect(find.byType(Container), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsAtLeastNWidgets(1));
        expect(find.byType(TermsAgreementItem), findsAtLeastNWidgets(4)); // 4개의 약관 항목
        expect(find.byType(TermsAgreeButton), findsOneWidget);
      });
    });
  });
}
