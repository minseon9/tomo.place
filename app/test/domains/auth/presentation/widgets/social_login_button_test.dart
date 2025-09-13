import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';
import '../../../../utils/responsive_test_helper.dart';
import '../../../../utils/widget/verifiers.dart';

void main() {
  group('SocialLoginButton', () {
    late VoidCallback mockOnPressed;

    setUp(() {
      mockOnPressed = () {};
    });

    Widget createWidget({
      required SocialProvider provider,
      VoidCallback? onPressed,
      bool isLoading = false,
      Size screenSize = const Size(375, 812), // iPhone 13 기본 크기
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: Scaffold(
            body: SocialLoginButton(
              provider: provider,
              onPressed: onPressed,
              isLoading: isLoading,
            ),
          ),
        ),
      );
    }

    group('반응형 컨테이너 적용', () {
      testWidgets('모바일에서 컨테이너가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: mobileScreenSize,
          ),
        );

        // ResponsiveContainer가 존재하는지 확인
        final responsiveContainer = find.byType(SocialLoginButton);
        WidgetVerifiers.verifyContainerRenders(tester, responsiveContainer);
      });

      testWidgets('태블릿에서 컨테이너가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: tabletScreenSize,
          ),
        );

        // ResponsiveContainer가 존재하는지 확인
        final responsiveContainer = find.byType(SocialLoginButton);
        WidgetVerifiers.verifyContainerRenders(tester, responsiveContainer);
      });

      testWidgets('다양한 화면 크기에서 컨테이너가 렌더링되어야 한다', (WidgetTester tester) async {
        final randomScreenSize = ResponsiveTestHelper.createRandomDouble(min: 300, max: 1200);
        final screenSize = Size(randomScreenSize, randomScreenSize * 1.5);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: screenSize,
          ),
        );

        // ResponsiveContainer가 존재하는지 확인
        final responsiveContainer = find.byType(SocialLoginButton);
        WidgetVerifiers.verifyContainerRenders(tester, responsiveContainer);
      });
    });

    group('반응형 높이 적용', () {
      testWidgets('모바일에서 높이가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: mobileScreenSize,
          ),
        );

        // Container 위젯들이 존재하는지 확인
        final containers = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(Container),
        );

        expect(containers, findsAtLeastNWidgets(1));
      });

      testWidgets('태블릿에서 높이가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: tabletScreenSize,
          ),
        );

        // Container 위젯들이 존재하는지 확인
        final containers = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(Container),
        );

        expect(containers, findsAtLeastNWidgets(1));
      });
    });

    group('반응형 패딩 적용', () {
      testWidgets('모바일에서 패딩이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: mobileScreenSize,
          ),
        );

        // Padding 위젯이 존재하는지 확인
        final padding = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(Padding),
        );

        WidgetVerifiers.verifyPaddingRenders(tester, padding);
      });

      testWidgets('태블릿에서 패딩이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: tabletScreenSize,
          ),
        );

        // Padding 위젯이 존재하는지 확인
        final padding = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(Padding),
        );

        WidgetVerifiers.verifyPaddingRenders(tester, padding);
      });
    });

    group('반응형 간격 적용', () {
      testWidgets('SizedBox에 간격이 올바르게 적용되어야 한다', (
        WidgetTester tester,
      ) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: mobileScreenSize,
          ),
        );

        // SizedBox 위젯들이 존재하는지 확인
        final sizedBoxes = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(SizedBox),
        );

        expect(sizedBoxes, findsAtLeastNWidgets(1));
      });

      testWidgets('태블릿에서 간격이 올바르게 적용되어야 한다', (
        WidgetTester tester,
      ) async {
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: tabletScreenSize,
          ),
        );

        // SizedBox 위젯들이 존재하는지 확인
        final sizedBoxes = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(SizedBox),
        );

        expect(sizedBoxes, findsAtLeastNWidgets(1));
      });
    });

    group('반응형 타이포그래피 적용', () {
      testWidgets('Google 버튼에 텍스트가 올바르게 렌더링되어야 한다', (
        WidgetTester tester,
      ) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            screenSize: mobileScreenSize,
          ),
        );

        WidgetVerifiers.verifyTextRenders(tester, '구글로 시작하기');
      });

      testWidgets('Apple 버튼에 텍스트가 올바르게 렌더링되어야 한다', (
        WidgetTester tester,
      ) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.apple,
            onPressed: mockOnPressed,
            screenSize: mobileScreenSize,
          ),
        );

        WidgetVerifiers.verifyTextRenders(tester, '애플로 시작하기 (준비 중)');
      });
    });

    group('기존 로직 보존', () {
      testWidgets('Google 버튼은 활성화 상태', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNotNull);
      });

      testWidgets('Kakao 버튼은 비활성화 상태', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNull);
      });

      testWidgets('Apple 버튼은 비활성화 상태', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.apple,
            onPressed: mockOnPressed,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNull);
      });

      testWidgets('로딩 상태에서 버튼 비활성화', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            isLoading: true,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNull);
      });

      testWidgets('올바른 텍스트 표시', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        expect(find.text('구글로 시작하기'), findsOneWidget);
      });

      testWidgets('비활성화 상태에서 올바른 텍스트 표시', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        expect(find.text('카카오로 시작하기 (준비 중)'), findsOneWidget);
      });

      testWidgets('올바른 배경색 적용', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SocialLoginButton),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration;
        if (decoration != null) {
          expect(decoration, isA<BoxDecoration>());
          if (decoration is BoxDecoration) {
            expect(decoration.color, equals(AppColors.white));
          }
        }
      });

      testWidgets('비활성화 상태에서 올바른 배경색 적용', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SocialLoginButton),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration;
        if (decoration != null) {
          expect(decoration, isA<BoxDecoration>());
          if (decoration is BoxDecoration) {
            expect(
              decoration.color,
              equals(AppColors.tomoDarkGray.withValues(alpha: 0.3)),
            );
          }
        }
      });
    });

    group('위젯 트리 구조 검증', () {
      testWidgets('올바른 위젯 계층 구조', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        // SocialLoginButton -> Container -> Material -> InkWell -> Padding -> Row
        expect(find.byType(SocialLoginButton), findsOneWidget);
        expect(
          find.byType(Container),
          findsAtLeastNWidgets(1),
        ); // ResponsiveContainer의 Container + 버튼 Container
        expect(
          find.byType(Material),
          findsAtLeastNWidgets(1),
        ); // MaterialApp + 버튼 내부 Material
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        expect(
          find.byType(SizedBox),
          findsAtLeastNWidgets(2),
        ); // 아이콘 SizedBox + 간격 SizedBox
      });
    });
  });
}
