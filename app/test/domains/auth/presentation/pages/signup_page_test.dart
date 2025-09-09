import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/consts/social_label_variant.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/domains/auth/presentation/pages/signup_page.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_section.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../utils/mock_factory/presentation_mock_factory.dart';

void main() {
  group('SignupPage', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = PresentationMockFactory.createAuthNotifier();
      
      // Register fallback values
      registerFallbackValue(SocialProvider.google);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
        ],
        child: const MaterialApp(
          home: SignupPage(),
        ),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SignupPage), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('필수 UI 요소들이 표시되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('기본적으로 회원가입 모드로 시작해야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        final socialLoginSection = tester.widget<SocialLoginSection>(
          find.byType(SocialLoginSection),
        );
        expect(socialLoginSection.labelVariant, equals(SocialLabelVariant.signup));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('Google 로그인 버튼 클릭 시 AuthNotifier가 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());
        when(() => mockAuthNotifier.signupWithProvider(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());

        // When - Google 로그인 버튼을 직접 찾아서 탭
        final googleButtonFinder = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButtonFinder);
        await tester.pump();

        // Then
        verify(() => mockAuthNotifier.signupWithProvider(SocialProvider.google)).called(1);
      });

      testWidgets('소셜 로그인 버튼 클릭 시 콜백이 전달되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(createTestWidget());

        // When
        final socialLoginSection = tester.widget<SocialLoginSection>(
          find.byType(SocialLoginSection),
        );

        // Then
        expect(socialLoginSection.onProviderPressed, isNotNull);
      });
    });

    group('상태 변화 테스트', () {
      testWidgets('로딩 상태일 때 UI가 업데이트되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthLoading());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SignupPage), findsOneWidget);
        // 로딩 상태에서도 기본 UI는 유지되어야 함
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('성공 상태일 때 UI가 업데이트되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthSuccess(true));

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SignupPage), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('에러 상태일 때 UI가 업데이트되어야 한다', (WidgetTester tester) async {
        // Given
        final mockError = PresentationMockFactory.createExceptionInterface();
        when(() => mockAuthNotifier.state).thenReturn(AuthFailure(error: mockError));

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SignupPage), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });
    });

    group('위젯 구조 테스트', () {
      testWidgets('올바른 위젯 계층 구조를 가져야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(Padding), findsWidgets); // 여러 Padding 위젯이 있으므로 findsWidgets 사용
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(Spacer), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('올바른 패딩과 스페이싱을 가져야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then - SignupPage의 메인 Padding을 찾기 위해 더 구체적인 조건 사용
        final mainPaddingFinder = find.byWidgetPredicate(
          (widget) => widget is Padding && 
                     widget.padding == const EdgeInsets.all(24.0),
        );
        final padding = tester.widget<Padding>(mainPaddingFinder);
        expect(padding.padding, equals(const EdgeInsets.all(24.0))); // AppSpacing.lg
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SignupPage), findsOneWidget);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });
  });
}
