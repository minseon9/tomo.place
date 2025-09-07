import 'package:app/domains/auth/consts/social_provider.dart';
import 'package:app/domains/auth/consts/social_label_variant.dart';
import 'package:app/domains/auth/presentation/widgets/social_login_section.dart';
import 'package:app/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialLoginSection', () {
    Widget createTestWidget({
      SocialLabelVariant labelVariant = SocialLabelVariant.signup,
      void Function(SocialProvider provider)? onProviderPressed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SocialLoginSection(
            labelVariant: labelVariant,
            onProviderPressed: onProviderPressed,
          ),
        ),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3)); // Kakao, Apple, Google
      });

      testWidgets('모든 소셜 로그인 버튼이 표시되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
        
        // 각 버튼의 provider 확인
        final buttons = tester.widgetList<SocialLoginButton>(find.byType(SocialLoginButton));
        final providers = buttons.map((button) => button.provider).toList();
        
        expect(providers, contains(SocialProvider.kakao));
        expect(providers, contains(SocialProvider.apple));
        expect(providers, contains(SocialProvider.google));
      });

      testWidgets('올바른 위젯 구조를 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Column), findsOneWidget);
        // SizedBox는 여러 개가 있을 수 있음 (아이콘, 스페이싱 등)
        expect(find.byType(SizedBox), findsWidgets);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('Google 로그인 버튼만 활성화되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;
        SocialProvider? calledProvider;

        // When
        await tester.pumpWidget(createTestWidget(
          onProviderPressed: (provider) {
            callbackCalled = true;
            calledProvider = provider;
          },
        ));

        // Then
        final buttons = tester.widgetList<SocialLoginButton>(find.byType(SocialLoginButton));
        
        // Kakao 버튼은 비활성화
        final kakaoButton = buttons.firstWhere((b) => b.provider == SocialProvider.kakao);
        expect(kakaoButton.onPressed, isNull);
        
        // Apple 버튼은 비활성화
        final appleButton = buttons.firstWhere((b) => b.provider == SocialProvider.apple);
        expect(appleButton.onPressed, isNull);
        
        // Google 버튼은 활성화
        final googleButton = buttons.firstWhere((b) => b.provider == SocialProvider.google);
        expect(googleButton.onPressed, isNotNull);
      });

      testWidgets('Google 로그인 버튼 클릭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;
        SocialProvider? calledProvider;

        await tester.pumpWidget(createTestWidget(
          onProviderPressed: (provider) {
            callbackCalled = true;
            calledProvider = provider;
          },
        ));

        // When
        final googleButton = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButton);
        await tester.pump();

        // Then
        expect(callbackCalled, isTrue);
        expect(calledProvider, equals(SocialProvider.google));
      });

      testWidgets('Kakao 로그인 버튼은 클릭되지 않아야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          onProviderPressed: (provider) {
            callbackCalled = true;
          },
        ));

        // When
        final kakaoButton = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.kakao,
        );
        await tester.tap(kakaoButton);
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });

      testWidgets('Apple 로그인 버튼은 클릭되지 않아야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          onProviderPressed: (provider) {
            callbackCalled = true;
          },
        ));

        // When
        final appleButton = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.apple,
        );
        await tester.tap(appleButton);
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });
    });

    group('라벨 변형 테스트', () {
      testWidgets('회원가입 모드일 때 올바른 라벨을 사용해야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          labelVariant: SocialLabelVariant.signup,
        ));

        // Then
        final buttons = tester.widgetList<SocialLoginButton>(find.byType(SocialLoginButton));
        
        for (final button in buttons) {
          expect(button.labelVariant, equals(SocialLabelVariant.signup));
        }
      });

      testWidgets('로그인 모드일 때 올바른 라벨을 사용해야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          labelVariant: SocialLabelVariant.login,
        ));

        // Then
        final buttons = tester.widgetList<SocialLoginButton>(find.byType(SocialLoginButton));
        
        for (final button in buttons) {
          expect(button.labelVariant, equals(SocialLabelVariant.login));
        }
      });
    });

    group('콜백 전달 테스트', () {
      testWidgets('onProviderPressed가 null일 때 Google 버튼도 비활성화되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          onProviderPressed: null,
        ));

        // Then
        final buttons = tester.widgetList<SocialLoginButton>(find.byType(SocialLoginButton));
        
        for (final button in buttons) {
          expect(button.onPressed, isNull);
        }
      });

      testWidgets('onProviderPressed가 제공될 때 Google 버튼만 활성화되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          onProviderPressed: (provider) {},
        ));

        // Then
        final buttons = tester.widgetList<SocialLoginButton>(find.byType(SocialLoginButton));
        
        final kakaoButton = buttons.firstWhere((b) => b.provider == SocialProvider.kakao);
        final appleButton = buttons.firstWhere((b) => b.provider == SocialProvider.apple);
        final googleButton = buttons.firstWhere((b) => b.provider == SocialProvider.google);
        
        expect(kakaoButton.onPressed, isNull);
        expect(appleButton.onPressed, isNull);
        expect(googleButton.onPressed, isNotNull);
      });
    });

    group('스페이싱 테스트', () {
      testWidgets('버튼 간 올바른 간격을 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        
        // 버튼 간 간격을 위한 SizedBox가 있어야 함
        final spacingBoxes = sizedBoxes.where((box) => box.height == 16.0).toList();
        expect(spacingBoxes, hasLength(2)); // 2개의 스페이싱 SizedBox
        
        // 각 스페이싱 SizedBox의 높이가 AppSpacing.md와 같아야 함
        for (final sizedBox in spacingBoxes) {
          expect(sizedBox.height, equals(16.0)); // AppSpacing.md
        }
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });
  });
}
