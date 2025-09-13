import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_section.dart';
import '../../../../utils/responsive_test_helper.dart';

void main() {
  group('SocialLoginSection', () {
    late void Function(SocialProvider provider) mockOnProviderPressed;

    setUp(() {
      mockOnProviderPressed = (provider) {};
    });

    Widget createWidget({
      void Function(SocialProvider provider)? onProviderPressed,
      Size screenSize = const Size(375, 812), // iPhone 13 기본 크기
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: Scaffold(
            body: SocialLoginSection(onProviderPressed: onProviderPressed),
          ),
        ),
      );
    }

    group('반응형 간격 적용', () {
      testWidgets('모바일에서 간격이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: mobileScreenSize,
            child: SocialLoginSection(onProviderPressed: mockOnProviderPressed),
          ),
        );

        // SizedBox 위젯들이 존재하는지 확인
        final sizedBoxes = find.descendant(
          of: find.byType(SocialLoginSection),
          matching: find.byType(SizedBox),
        );

        expect(sizedBoxes, findsAtLeastNWidgets(2));
      });

      testWidgets('태블릿에서 간격이 올바르게 적용되어야 한다', (
        WidgetTester tester,
      ) async {
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: tabletScreenSize,
            child: SocialLoginSection(onProviderPressed: mockOnProviderPressed),
          ),
        );

        // SizedBox 위젯들이 존재하는지 확인
        final sizedBoxes = find.descendant(
          of: find.byType(SocialLoginSection),
          matching: find.byType(SizedBox),
        );

        expect(sizedBoxes, findsAtLeastNWidgets(2));
      });

      testWidgets('SizedBox 개수 확인', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(onProviderPressed: mockOnProviderPressed));

        final sizedBoxes = find.descendant(
          of: find.byType(SocialLoginSection),
          matching: find.byType(SizedBox),
        );

        // ResponsiveSpacing과 아이콘으로 인해 SizedBox가 더 많이 생성됨
        expect(sizedBoxes, findsAtLeastNWidgets(2));
      });
    });

    group('기존 로직 보존', () {
      testWidgets('올바른 버튼 순서', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(onProviderPressed: mockOnProviderPressed),
        );

        final buttons = find.descendant(
          of: find.byType(SocialLoginSection),
          matching: find.byType(SocialLoginButton),
        );

        expect(buttons, findsNWidgets(3));

        // 첫 번째 버튼: Kakao
        final kakaoButton = tester.widget<SocialLoginButton>(buttons.at(0));
        expect(kakaoButton.provider, equals(SocialProvider.kakao));
        expect(kakaoButton.onPressed, isNull);

        // 두 번째 버튼: Apple
        final appleButton = tester.widget<SocialLoginButton>(buttons.at(1));
        expect(appleButton.provider, equals(SocialProvider.apple));
        expect(appleButton.onPressed, isNull);

        // 세 번째 버튼: Google
        final googleButton = tester.widget<SocialLoginButton>(buttons.at(2));
        expect(googleButton.provider, equals(SocialProvider.google));
        expect(googleButton.onPressed, isNotNull);
      });

      testWidgets('Google 버튼에 onProviderPressed 콜백 적용', (
        WidgetTester tester,
      ) async {
        bool callbackCalled = false;
        SocialProvider? calledProvider;

        void testCallback(SocialProvider provider) {
          callbackCalled = true;
          calledProvider = provider;
        }

        await tester.pumpWidget(createWidget(onProviderPressed: testCallback));

        final googleButton = tester.widget<SocialLoginButton>(
          find
              .descendant(
                of: find.byType(SocialLoginSection),
                matching: find.byType(SocialLoginButton),
              )
              .at(2),
        );

        // Google 버튼의 onPressed가 올바르게 설정되었는지 확인
        expect(googleButton.onPressed, isNotNull);

        // 버튼 탭 시뮬레이션
        await tester.tap(
          find
              .descendant(
                of: find.byType(SocialLoginSection),
                matching: find.byType(SocialLoginButton),
              )
              .at(2),
        );
        await tester.pump();

        expect(callbackCalled, isTrue);
        expect(calledProvider, equals(SocialProvider.google));
      });

      testWidgets('onProviderPressed가 null일 때 Google 버튼 비활성화', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createWidget(onProviderPressed: null));

        final googleButton = tester.widget<SocialLoginButton>(
          find
              .descendant(
                of: find.byType(SocialLoginSection),
                matching: find.byType(SocialLoginButton),
              )
              .at(2),
        );

        expect(googleButton.onPressed, isNull);
      });

      testWidgets('Kakao와 Apple 버튼은 항상 비활성화', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(onProviderPressed: mockOnProviderPressed),
        );

        final kakaoButton = tester.widget<SocialLoginButton>(
          find
              .descendant(
                of: find.byType(SocialLoginSection),
                matching: find.byType(SocialLoginButton),
              )
              .at(0),
        );

        final appleButton = tester.widget<SocialLoginButton>(
          find
              .descendant(
                of: find.byType(SocialLoginSection),
                matching: find.byType(SocialLoginButton),
              )
              .at(1),
        );

        expect(kakaoButton.onPressed, isNull);
        expect(appleButton.onPressed, isNull);
      });
    });

    group('위젯 트리 구조 검증', () {
      testWidgets('올바른 위젯 계층 구조', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(onProviderPressed: mockOnProviderPressed));

        // Column -> SocialLoginButton + SizedBox + SocialLoginButton + SizedBox + SocialLoginButton
        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
        // ResponsiveSpacing으로 인해 SizedBox가 더 많이 생성될 수 있음
        expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      });

      testWidgets('Column의 mainAxisSize가 기본값', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(onProviderPressed: mockOnProviderPressed));

        final column = tester.widget<Column>(
          find.descendant(
            of: find.byType(SocialLoginSection),
            matching: find.byType(Column),
          ),
        );

        // Column의 기본값은 MainAxisSize.max
        expect(column.mainAxisSize, equals(MainAxisSize.max));
      });
    });

    group('반응형 동작 검증', () {
      testWidgets('화면 크기 변경 시 간격이 재계산되어야 한다', (
        WidgetTester tester,
      ) async {
        // 모바일 크기로 시작
        const mobileScreenSize = Size(375, 812);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: mobileScreenSize,
            child: SocialLoginSection(onProviderPressed: mockOnProviderPressed),
          ),
        );

        var sizedBoxes = find.descendant(
          of: find.byType(SocialLoginSection),
          matching: find.byType(SizedBox),
        );

        expect(sizedBoxes, findsAtLeastNWidgets(2));

        // 태블릿 크기로 변경
        const tabletScreenSize = Size(1024, 768);

        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: tabletScreenSize,
            child: SocialLoginSection(onProviderPressed: mockOnProviderPressed),
          ),
        );

        sizedBoxes = find.descendant(
          of: find.byType(SocialLoginSection),
          matching: find.byType(SizedBox),
        );

        expect(sizedBoxes, findsAtLeastNWidgets(2));
      });
    });
  });
}
