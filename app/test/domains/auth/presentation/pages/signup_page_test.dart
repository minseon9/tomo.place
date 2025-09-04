import 'package:app/domains/auth/consts/social_label_variant.dart';
import 'package:app/domains/auth/consts/social_provider.dart';
import 'package:app/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:app/domains/auth/presentation/models/auth_state.dart';
import 'package:app/domains/auth/presentation/pages/signup_page.dart';
import 'package:app/domains/auth/presentation/widgets/social_login_section.dart';
import 'package:app/shared/error_handling/exceptions/generic_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../utils/widget_test_utils.dart';

class _MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  group('SignupPage', () {
    late _MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = _MockAuthNotifier();
    });

    group('렌더링 테스트', () {
      testWidgets('기본적으로 회원가입 모드로 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        expect(find.byType(SignupPage), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);

        // 회원가입 모드인지 확인
        final socialLoginSection = tester.widget<SocialLoginSection>(
          find.byType(SocialLoginSection),
        );
        expect(
          socialLoginSection.labelVariant,
          equals(SocialLabelVariant.signup),
        );
      });

      testWidgets('올바른 배경색을 가져야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNotNull);
      });

      testWidgets('SafeArea로 감싸져야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        expect(find.byType(SafeArea), findsOneWidget);
      });
    });

    group('상태 변화 테스트', () {
      testWidgets('AuthSuccess 상태일 때 홈 페이지로 이동해야 한다', (
        WidgetTester tester,
      ) async {
        final mockNavigatorObserver = _MockNavigatorObserver();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: MaterialApp(
              home: const SignupPage(),
              navigatorObservers: [mockNavigatorObserver],
              routes: {
                '/home': (context) => const Scaffold(body: Text('Home Page')),
              },
            ),
          ),
        );

        // AuthSuccess 상태로 변경
        when(() => mockAuthNotifier.state).thenReturn(const AuthSuccess(true));

        // 상태 변화를 트리거하기 위해 다시 빌드
        await tester.pump();

        // Navigator.pushReplacementNamed이 호출되었는지 확인
        verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      });

      testWidgets('AuthLoading 상태일 때 로딩 상태를 표시해야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        when(() => mockAuthNotifier.state).thenReturn(const AuthLoading());

        await tester.pump();

        // 로딩 상태에서도 기본 UI는 유지되어야 함
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('AuthFailure 상태일 때 에러 상태를 표시해야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        when(() => mockAuthNotifier.state).thenReturn(
          AuthFailure(
            error: GenericException.fromException(Exception('Test error')),
          ),
        );

        await tester.pump();

        // 에러 상태에서도 기본 UI는 유지되어야 함
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });
    });

    group('상호작용 테스트', () {
      testWidgets('소셜 로그인 버튼 탭 시 올바른 메서드가 호출되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        // Google 로그인 버튼 찾기 및 탭
        final googleButton = find.textContaining('구글');
        expect(googleButton, findsOneWidget);

        await tester.tap(googleButton);
        await tester.pump();

        // signupWithProvider 메서드가 호출되었는지 확인
        verify(
          () => mockAuthNotifier.signupWithProvider(SocialProvider.google),
        ).called(1);
      });

      testWidgets('Apple 로그인 버튼 탭 시 올바른 메서드가 호출되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        // Apple 로그인 버튼 찾기 및 탭
        final appleButton = find.textContaining('애플');
        expect(appleButton, findsOneWidget);

        await tester.tap(appleButton);
        await tester.pump();

        // signupWithProvider 메서드가 호출되었는지 확인
        verify(
          () => mockAuthNotifier.signupWithProvider(SocialProvider.apple),
        ).called(1);
      });

      testWidgets('Kakao 로그인 버튼 탭 시 올바른 메서드가 호출되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        // Kakao 로그인 버튼 찾기 및 탭
        final kakaoButton = find.textContaining('카카오');
        expect(kakaoButton, findsOneWidget);

        await tester.tap(kakaoButton);
        await tester.pump();

        // signupWithProvider 메서드가 호출되었는지 확인
        verify(
          () => mockAuthNotifier.signupWithProvider(SocialProvider.kakao),
        ).called(1);
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('올바른 패딩을 가져야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        final padding = tester.widget<Padding>(find.byType(Padding).first);
        expect(
          padding.padding,
          equals(const EdgeInsets.all(24.0)),
        ); // AppSpacing.lg
      });

      testWidgets('Column 레이아웃이 올바르게 구성되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        expect(
          find.byType(Column),
          findsNWidgets(2),
        ); // 메인 Column과 Center 내부 Column
        expect(find.byType(Spacer), findsOneWidget);
        expect(find.byType(SizedBox), findsNWidgets(2)); // 두 개의 SizedBox
      });
    });

    group('접근성 테스트', () {
      testWidgets('모든 소셜 로그인 버튼이 접근 가능해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ],
            child: WidgetTestUtils.wrapWithMaterialAppAndNavigator(
              const SignupPage(),
            ),
          ),
        );

        // 모든 소셜 로그인 버튼이 표시되어야 함
        expect(find.textContaining('구글'), findsOneWidget);
        expect(find.textContaining('애플'), findsOneWidget);
        expect(find.textContaining('카카오'), findsOneWidget);
      });
    });
  });
}

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}
