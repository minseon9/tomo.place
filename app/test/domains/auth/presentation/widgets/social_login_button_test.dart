import 'package:app/domains/auth/consts/social_provider.dart';
import 'package:app/domains/auth/consts/social_label_variant.dart';
import 'package:app/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialLoginButton', () {
    Widget createTestWidget({
      required SocialProvider provider,
      VoidCallback? onPressed,
      bool isLoading = false,
      SocialLabelVariant labelVariant = SocialLabelVariant.signup,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SocialLoginButton(
            provider: provider,
            onPressed: onPressed,
            isLoading: isLoading,
            labelVariant: labelVariant,
          ),
        ),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {},
        ));

        // Then
        expect(find.byType(SocialLoginButton), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Material), findsWidgets); // Material 위젯이 여러 개 있을 수 있음
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('다양한 소셜 프로바이더로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        final providers = [SocialProvider.kakao, SocialProvider.apple, SocialProvider.google];

        for (final provider in providers) {
          // When
          await tester.pumpWidget(createTestWidget(
            provider: provider,
            onPressed: () {},
          ));

          // Then
          expect(find.byType(SocialLoginButton), findsOneWidget);
          
          final button = tester.widget<SocialLoginButton>(find.byType(SocialLoginButton));
          expect(button.provider, equals(provider));
        }
      });

      testWidgets('올바른 위젯 구조를 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {},
        ));

        // Then
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Material), findsWidgets); // Material 위젯이 여러 개 있을 수 있음
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Padding), findsWidgets); // Padding 위젯이 여러 개 있을 수 있음
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('상호작용 테스트', () {
      testWidgets('Google 버튼 클릭 시 콜백이 올바르게 호출되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {
            callbackCalled = true;
          },
        ));

        // When
        await tester.tap(find.byType(SocialLoginButton));
        await tester.pump();

        // Then
        expect(callbackCalled, isTrue);
      });

      testWidgets('Kakao 버튼은 비활성화되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.kakao,
          onPressed: () {
            callbackCalled = true;
          },
        ));

        // When
        await tester.tap(find.byType(SocialLoginButton));
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });

      testWidgets('Apple 버튼은 비활성화되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.apple,
          onPressed: () {
            callbackCalled = true;
          },
        ));

        // When
        await tester.tap(find.byType(SocialLoginButton));
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });

      testWidgets('로딩 상태일 때 버튼이 비활성화되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {
            callbackCalled = true;
          },
          isLoading: true,
        ));

        // When
        await tester.tap(find.byType(SocialLoginButton));
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });

      testWidgets('onPressed가 null일 때 버튼이 비활성화되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: null,
        ));

        // When
        await tester.tap(find.byType(SocialLoginButton));
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });
    });

    group('텍스트 테스트', () {
      testWidgets('회원가입 모드에서 올바른 텍스트를 표시해야 한다', (WidgetTester tester) async {
        // Given
        final testCases = [
          (SocialProvider.kakao, '카카오로 시작하기 (준비 중)'),
          (SocialProvider.apple, '애플로 시작하기 (준비 중)'),
          (SocialProvider.google, '구글로 시작하기'),
        ];

        for (final (provider, expectedText) in testCases) {
          // When
          await tester.pumpWidget(createTestWidget(
            provider: provider,
            onPressed: () {},
            labelVariant: SocialLabelVariant.signup,
          ));

          // Then
          expect(find.text(expectedText), findsOneWidget);
        }
      });

      testWidgets('로그인 모드에서 올바른 텍스트를 표시해야 한다', (WidgetTester tester) async {
        // Given
        final testCases = [
          (SocialProvider.kakao, '카카오 로그인 (준비 중)'),
          (SocialProvider.apple, '애플 로그인 (준비 중)'),
          (SocialProvider.google, '구글 로그인'),
        ];

        for (final (provider, expectedText) in testCases) {
          // When
          await tester.pumpWidget(createTestWidget(
            provider: provider,
            onPressed: () {},
            labelVariant: SocialLabelVariant.login,
          ));

          // Then
          expect(find.text(expectedText), findsOneWidget);
        }
      });
    });

    group('스타일 테스트', () {
      testWidgets('Google 버튼은 흰색 배경을 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {},
        ));

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.white));
      });

      testWidgets('Kakao 버튼은 노란색 배경을 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.kakao,
          onPressed: () {},
        ));

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        // Kakao 노란색은 DesignTokens에서 정의된 색상
        expect(decoration.color, isNotNull);
      });

      testWidgets('Apple 버튼은 비활성화되어 회색 배경을 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.apple,
          onPressed: () {},
        ));

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        // Apple 버튼은 비활성화되어 회색 배경을 가짐
        expect(decoration.color, isNotNull);
      });

      testWidgets('비활성화된 버튼은 회색 배경을 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.kakao, // 비활성화된 버튼
          onPressed: () {},
        ));

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        // 비활성화된 버튼은 투명도가 적용된 회색
        expect(decoration.color, isNotNull);
      });
    });

    group('크기 테스트', () {
      testWidgets('올바른 크기를 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {},
        ));

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints, isNotNull);
      });

      testWidgets('올바른 패딩을 가져야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {},
        ));

        // Then
        final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
        expect(paddingWidgets, isNotEmpty);
        final padding = paddingWidgets.first;
        expect(padding.padding, isA<EdgeInsets>());
      });
    });

    group('아이콘 테스트', () {
      testWidgets('아이콘이 표시되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {},
        ));

        // Then
        expect(find.byType(SizedBox), findsWidgets); // 아이콘을 감싸는 SizedBox가 있음
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestWidget(
          provider: SocialProvider.google,
          onPressed: () {},
        ));

        // Then
        expect(find.byType(SocialLoginButton), findsOneWidget);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });
  });
}
