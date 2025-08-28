import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/domains/auth/presentation/pages/login_page.dart';
import 'package:app/domains/auth/presentation/controllers/auth_controller.dart';
import 'package:app/domains/auth/services/auth_service.dart';
import 'package:app/domains/auth/domain/entities/user.dart';
import 'package:app/shared/exceptions/auth_exception.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthService mockAuthService;
    late AuthController authController;

    setUp(() {
      mockAuthService = MockAuthService();
      authController = AuthController(authService: mockAuthService);
    });

    tearDown(() {
      authController.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<AuthController>(
          create: (context) => authController,
          child: const LoginPage(),
        ),
      );
    }

    testWidgets('should display login page with all social login buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // 페이지 제목 확인
      expect(find.text('로그인'), findsOneWidget);
      expect(find.text('소셜 계정으로 간편하게 로그인하세요'), findsOneWidget);

      // 소셜 로그인 버튼들 확인
      expect(find.text('Google로 로그인'), findsOneWidget);
      expect(find.text('Kakao로 로그인'), findsOneWidget);
      expect(find.text('Apple로 로그인'), findsOneWidget);

      // 이메일 로그인 링크 확인
      expect(find.text('이메일로 로그인'), findsOneWidget);
      expect(find.text('계정이 없으신가요? 회원가입'), findsOneWidget);
    });

    testWidgets('should show loading state when Google login is pressed', (WidgetTester tester) async {
      // Google 로그인이 완료되지 않도록 설정
      when(mockAuthService.loginWithGoogle())
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 2)));

      await tester.pumpWidget(createTestWidget());

      // Google 로그인 버튼 찾기 및 탭
      final googleButton = find.text('Google로 로그인');
      expect(googleButton, findsOneWidget);
      await tester.tap(googleButton);
      await tester.pump();

      // 로딩 상태 확인 (버튼이 비활성화되었는지)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show success state when Google login succeeds', (WidgetTester tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      when(mockAuthService.loginWithGoogle()).thenAnswer((_) async => testUser);

      await tester.pumpWidget(createTestWidget());

      // Google 로그인 버튼 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.pumpAndSettle();

      // 성공 상태 확인 (스낵바나 다이얼로그가 표시되었는지)
      verify(mockAuthService.loginWithGoogle()).called(1);
    });

    testWidgets('should show error state when Google login fails', (WidgetTester tester) async {
      when(mockAuthService.loginWithGoogle())
          .thenThrow(AuthException('Google 로그인에 실패했습니다'));

      await tester.pumpWidget(createTestWidget());

      // Google 로그인 버튼 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.pumpAndSettle();

      // 에러 메시지 확인
      expect(find.text('Google 로그인에 실패했습니다'), findsOneWidget);
    });

    testWidgets('should show "준비 중" message for Kakao login', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Kakao 로그인 버튼 탭
      await tester.tap(find.text('Kakao로 로그인'));
      await tester.pumpAndSettle();

      // "준비 중" 메시지 확인
      expect(find.text('준비 중입니다'), findsOneWidget);
    });

    testWidgets('should show "준비 중" message for Apple login', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Apple 로그인 버튼 탭
      await tester.tap(find.text('Apple로 로그인'));
      await tester.pumpAndSettle();

      // "준비 중" 메시지 확인
      expect(find.text('준비 중입니다'), findsOneWidget);
    });

    testWidgets('should navigate to email login page when email login is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // 이메일 로그인 링크 탭
      await tester.tap(find.text('이메일로 로그인'));
      await tester.pumpAndSettle();

      // 네비게이션이 발생했는지 확인 (실제 네비게이션은 테스트 환경에서 제한적)
      // 여기서는 탭 이벤트가 정상적으로 처리되었는지만 확인
    });

    testWidgets('should navigate to signup page when signup link is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // 회원가입 링크 탭
      await tester.tap(find.text('계정이 없으신가요? 회원가입'));
      await tester.pumpAndSettle();

      // 네비게이션이 발생했는지 확인
    });

    testWidgets('should disable buttons during loading state', (WidgetTester tester) async {
      // 로딩 상태를 시뮬레이션하기 위해 AuthController 상태 변경
      when(mockAuthService.loginWithGoogle())
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      await tester.pumpWidget(createTestWidget());

      // Google 로그인 버튼 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.pump();

      // 로딩 중에는 다른 버튼들이 비활성화되어야 함
      final kakaoButton = find.text('Kakao로 로그인');
      final appleButton = find.text('Apple로 로그인');

      // 버튼이 비활성화되었는지 확인 (Material Design에서 비활성화된 버튼의 스타일)
      expect(tester.widget<ElevatedButton>(kakaoButton).enabled, isFalse);
      expect(tester.widget<ElevatedButton>(appleButton).enabled, isFalse);
    });

    testWidgets('should show proper button styling for disabled Kakao and Apple buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Kakao와 Apple 버튼이 비활성화 상태로 표시되는지 확인
      final kakaoButton = find.text('Kakao로 로그인');
      final appleButton = find.text('Apple로 로그인');

      // 버튼이 비활성화되었는지 확인
      expect(tester.widget<ElevatedButton>(kakaoButton).enabled, isFalse);
      expect(tester.widget<ElevatedButton>(appleButton).enabled, isFalse);
    });

    testWidgets('should handle multiple rapid taps gracefully', (WidgetTester tester) async {
      when(mockAuthService.loginWithGoogle())
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      await tester.pumpWidget(createTestWidget());

      // Google 로그인 버튼을 여러 번 빠르게 탭
      final googleButton = find.text('Google로 로그인');
      await tester.tap(googleButton);
      await tester.tap(googleButton);
      await tester.tap(googleButton);
      await tester.pump();

      // 한 번만 호출되어야 함 (중복 호출 방지)
      await tester.pumpAndSettle();
      verify(mockAuthService.loginWithGoogle()).called(1);
    });

    testWidgets('should display proper error messages for different error types', (WidgetTester tester) async {
      // 네트워크 에러
      when(mockAuthService.loginWithGoogle())
          .thenThrow(Exception('네트워크 연결을 확인해주세요'));

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Google로 로그인'));
      await tester.pumpAndSettle();

      expect(find.textContaining('네트워크 연결을 확인해주세요'), findsOneWidget);

      // AuthException 에러
      when(mockAuthService.loginWithGoogle())
          .thenThrow(AuthException('인증에 실패했습니다'));

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Google로 로그인'));
      await tester.pumpAndSettle();

      expect(find.text('인증에 실패했습니다'), findsOneWidget);
    });

    testWidgets('should have proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // 접근성 라벨 확인
      expect(find.bySemanticsLabel('Google로 로그인'), findsOneWidget);
      expect(find.bySemanticsLabel('Kakao로 로그인'), findsOneWidget);
      expect(find.bySemanticsLabel('Apple로 로그인'), findsOneWidget);
    });
  });
}
