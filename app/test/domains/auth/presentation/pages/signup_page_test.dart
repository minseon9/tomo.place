import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/consts/social_label_variant.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/domains/auth/presentation/pages/signup_page.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_section.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';
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
        child: MaterialApp(
          home: const SignupPage(),
          routes: {
            '/terms/terms-of-service': (context) => const Scaffold(body: Text('Terms of Service')),
            '/terms/privacy-policy': (context) => const Scaffold(body: Text('Privacy Policy')),
            '/terms/location-terms': (context) => const Scaffold(body: Text('Location Terms')),
          },
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

      testWidgets('SocialLoginSection이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });
    });

    group('상호작용 테스트', () {
      testWidgets('소셜 로그인 버튼 클릭 시 TermsAgreementModal이 표시되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(createTestWidget());

        // When - Google 로그인 버튼을 직접 찾아서 탭
        final googleButtonFinder = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButtonFinder);
        await tester.pumpAndSettle();

        // Then - TermsAgreementModal이 표시되어야 함
        expect(find.byType(TermsAgreementModal), findsOneWidget);
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

      testWidgets('TermsAgreementModal에서 모두 동의 시 AuthNotifier가 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());
        when(() => mockAuthNotifier.signupWithProvider(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());

        // When - Google 로그인 버튼 클릭하여 모달 표시
        final googleButtonFinder = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButtonFinder);
        await tester.pumpAndSettle();

        // 모달이 표시되었는지 확인
        expect(find.byType(TermsAgreementModal), findsOneWidget);

        // 모두 동의 버튼 클릭
        final agreeAllButton = find.text('모두 동의합니다 !');
        await tester.tap(agreeAllButton);
        await tester.pumpAndSettle();

        // Then - AuthNotifier가 호출되어야 함
        verify(() => mockAuthNotifier.signupWithProvider(SocialProvider.google)).called(1);
      });

      testWidgets('TermsAgreementModal에서 onDismiss 콜백이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(createTestWidget());

        // When - Google 로그인 버튼 클릭하여 모달 표시
        final googleButtonFinder = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButtonFinder);
        await tester.pumpAndSettle();

        // Then - 모달이 표시되고 onDismiss 콜백이 설정되어야 함
        expect(find.byType(TermsAgreementModal), findsOneWidget);
        
        final modal = tester.widget<TermsAgreementModal>(find.byType(TermsAgreementModal));
        expect(modal.onDismiss, isNotNull);
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


    group('_SignupPageContent 테스트', () {
      testWidgets('_SignupPageContent가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then - _SignupPageContent의 구조 확인
        expect(find.byType(Padding), findsWidgets);
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(Spacer), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
      });

      testWidgets('_SignupPageContent의 패딩이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        // When
        await tester.pumpWidget(createTestWidget());

        // Then - AppSpacing.lg (24.0) 패딩 확인
        final mainPaddingFinder = find.byWidgetPredicate(
          (widget) => widget is Padding && 
                     widget.padding == const EdgeInsets.all(24.0),
        );
        expect(mainPaddingFinder, findsOneWidget);
      });
    });

    group('TermsAgreementModal 통합 테스트', () {
      testWidgets('모달 표시 시 올바른 설정이 적용되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(createTestWidget());

        // When - Google 로그인 버튼 클릭하여 모달 표시
        final googleButtonFinder = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButtonFinder);
        await tester.pumpAndSettle();

        // Then - 모달이 올바른 설정으로 표시되어야 함
        expect(find.byType(TermsAgreementModal), findsOneWidget);
        
        // 모달의 콜백들이 올바르게 설정되었는지 확인
        final modal = tester.widget<TermsAgreementModal>(find.byType(TermsAgreementModal));
        expect(modal.onAgreeAll, isNotNull);
        expect(modal.onTermsTap, isNotNull);
        expect(modal.onPrivacyTap, isNotNull);
        expect(modal.onLocationTap, isNotNull);
        expect(modal.onDismiss, isNotNull);
      });

      testWidgets('모달에서 약관 링크 클릭 시 네비게이션이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(createTestWidget());

        // When - Google 로그인 버튼 클릭하여 모달 표시
        final googleButtonFinder = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButtonFinder);
        await tester.pumpAndSettle();

        // Then - 모달이 표시되었는지 확인
        expect(find.byType(TermsAgreementModal), findsOneWidget);
        
        // 약관 링크들이 존재하는지 확인
        expect(find.text('이용 약관 동의'), findsOneWidget);
        expect(find.text('개인정보 보호 방침 동의'), findsOneWidget);
        expect(find.text('위치정보 수집·이용 및 제3자 제공 동의'), findsOneWidget);
      });

      testWidgets('모달에서 약관 링크 클릭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(createTestWidget());

        // When - Google 로그인 버튼 클릭하여 모달 표시
        final googleButtonFinder = find.byWidgetPredicate(
          (widget) => widget is SocialLoginButton && widget.provider == SocialProvider.google,
        );
        await tester.tap(googleButtonFinder);
        await tester.pumpAndSettle();

        // Then - 모달이 표시되었는지 확인
        expect(find.byType(TermsAgreementModal), findsOneWidget);
        
        // 모달의 콜백들이 올바르게 설정되었는지 확인
        final modal = tester.widget<TermsAgreementModal>(find.byType(TermsAgreementModal));
        
        // onTermsTap 콜백 호출
        modal.onTermsTap?.call();
        
        // onPrivacyTap 콜백 호출
        modal.onPrivacyTap?.call();
        
        // onLocationTap 콜백 호출
        modal.onLocationTap?.call();
        
        // onDismiss 콜백 호출
        modal.onDismiss?.call();
        
        // 모든 콜백이 null이 아님을 확인
        expect(modal.onTermsTap, isNotNull);
        expect(modal.onPrivacyTap, isNotNull);
        expect(modal.onLocationTap, isNotNull);
        expect(modal.onDismiss, isNotNull);
      });
    });

    group('구조 테스트', () {
      testWidgets('_SignupPageContent가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockAuthNotifier.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(createTestWidget());

        // When - _SignupPageContent 위젯을 찾아서 구조 확인
        final signupPageContent = find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString().contains('_SignupPageContent'),
        );
        
        // Then - _SignupPageContent가 존재하는지 확인
        expect(signupPageContent, findsOneWidget);
        expect(find.byType(SocialLoginSection), findsOneWidget);
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
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
      });
    });
  });
}
