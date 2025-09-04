import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/domains/auth/consts/social_label_variant.dart';
import 'package:app/domains/auth/consts/social_provider.dart';
import 'package:app/domains/auth/presentation/widgets/social_login_section.dart';
import 'package:app/domains/auth/presentation/widgets/social_login_button.dart';

void main() {
  group('SocialLoginSection', () {
    group('렌더링 테스트', () {
      testWidgets('기본 signup 모드로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(),
            ),
          ),
        );

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
        
        // 각 제공자별 버튼이 있는지 확인
        expect(find.textContaining('카카오'), findsOneWidget);
        expect(find.textContaining('애플'), findsOneWidget);
        expect(find.textContaining('구글'), findsOneWidget);
      });

      testWidgets('login 모드로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(
                labelVariant: SocialLabelVariant.login,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
        
        // 로그인 텍스트가 있는지 확인
        expect(find.textContaining('로그인'), findsNWidgets(3));
      });

      testWidgets('콜백이 제공될 때 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;
        SocialProvider? calledProvider;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginSection(
                onProviderPressed: (provider) {
                  callbackCalled = true;
                  calledProvider = provider;
                },
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
        expect(callbackCalled, isFalse);
        expect(calledProvider, isNull);
      });
    });

    group('상호작용 테스트', () {
      testWidgets('Google 버튼 탭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;
        SocialProvider? calledProvider;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginSection(
                onProviderPressed: (provider) {
                  callbackCalled = true;
                  calledProvider = provider;
                },
              ),
            ),
          ),
        );

        // When
        final googleButton = find.textContaining('구글');
        await tester.tap(googleButton);
        await tester.pump();

        // Then
        expect(callbackCalled, isTrue);
        expect(calledProvider, equals(SocialProvider.google));
      });

      testWidgets('Kakao 버튼은 비활성화되어 있어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginSection(
                onProviderPressed: (provider) {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        );

        // When
        final kakaoButton = find.textContaining('카카오');
        await tester.tap(kakaoButton);
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });

      testWidgets('Apple 버튼은 비활성화되어 있어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginSection(
                onProviderPressed: (provider) {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        );

        // When
        final appleButton = find.textContaining('애플');
        await tester.tap(appleButton);
        await tester.pump();

        // Then
        expect(callbackCalled, isFalse);
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('올바른 간격으로 배치되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(),
            ),
          ),
        );

        // Then
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes.evaluate().length, greaterThanOrEqualTo(2));
        
        // 각 SizedBox의 높이가 AppSpacing.md인지 확인
        for (int i = 0; i < sizedBoxes.evaluate().length; i++) {
          final sizedBox = tester.widget<SizedBox>(sizedBoxes.at(i));
          if (sizedBox.height != null) {
            expect(sizedBox.height, equals(18.0)); // AppSpacing.md 실제 값
          }
        }
      });

      testWidgets('Column 구조로 올바르게 배치되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(),
            ),
          ),
        );

        // Then
        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
      });
    });

    group('라벨 변형 테스트', () {
      testWidgets('signup 모드에서 올바른 텍스트를 표시해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(
                labelVariant: SocialLabelVariant.signup,
              ),
            ),
          ),
        );

        // Then
        expect(find.textContaining('시작하기'), findsNWidgets(3));
        expect(find.textContaining('로그인'), findsNothing);
      });

      testWidgets('login 모드에서 올바른 텍스트를 표시해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(
                labelVariant: SocialLabelVariant.login,
              ),
            ),
          ),
        );

        // Then
        expect(find.textContaining('로그인'), findsNWidgets(3));
        expect(find.textContaining('시작하기'), findsNothing);
      });
    });

    group('접근성 테스트', () {
      testWidgets('모든 버튼이 접근 가능해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(),
            ),
          ),
        );

        // Then
        final buttons = find.byType(SocialLoginButton);
        expect(buttons, findsNWidgets(3));
        
        // 각 버튼이 렌더링되었는지 확인
        for (int i = 0; i < 3; i++) {
          expect(buttons.at(i), findsOneWidget);
        }
      });

      testWidgets('버튼 텍스트가 읽기 가능해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(),
            ),
          ),
        );

        // Then
        expect(find.textContaining('카카오'), findsOneWidget);
        expect(find.textContaining('애플'), findsOneWidget);
        expect(find.textContaining('구글'), findsOneWidget);
      });
    });

    group('에지 케이스', () {
      testWidgets('콜백이 null일 때도 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SocialLoginSection(
                onProviderPressed: null,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
      });

      testWidgets('빈 콜백으로도 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginSection(
                onProviderPressed: (_) {},
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
      });
    });

    group('불변성 테스트', () {
      testWidgets('위젯이 재빌드되어도 상태가 유지되어야 한다', (WidgetTester tester) async {
        // Given
        bool callbackCalled = false;
        SocialProvider? calledProvider;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginSection(
                onProviderPressed: (provider) {
                  callbackCalled = true;
                  calledProvider = provider;
                },
              ),
            ),
          ),
        );

        // When - 위젯 재빌드
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginSection(
                onProviderPressed: (provider) {
                  callbackCalled = true;
                  calledProvider = provider;
                },
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
        expect(find.byType(SocialLoginButton), findsNWidgets(3));
        expect(callbackCalled, isFalse);
        expect(calledProvider, isNull);
      });
    });
  });
}