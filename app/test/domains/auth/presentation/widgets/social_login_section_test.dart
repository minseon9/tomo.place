import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_section.dart';

void main() {
  group('SocialLoginSection', () {
    late void Function(SocialProvider provider) mockOnProviderPressed;

    setUp(() {
      mockOnProviderPressed = (provider) {};
    });

    Widget createWidget({
      void Function(SocialProvider provider)? onProviderPressed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SocialLoginSection(onProviderPressed: onProviderPressed),
        ),
      );
    }

    group('레이아웃 구조', () {
      testWidgets('SizedBox 위젯들이 존재해야 한다', (WidgetTester tester) async {
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

  });
}
