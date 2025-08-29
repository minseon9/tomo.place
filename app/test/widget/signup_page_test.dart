import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:app/domains/auth/presentation/pages/signup_page.dart';
import 'package:app/domains/auth/presentation/controllers/auth_controller.dart';
import 'package:app/domains/auth/services/auth_service.dart';

import 'signup_page_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('SignupPage Widget Tests', () {
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
          child: const SignupPage(),
        ),
      );
    }

    testWidgets('should display signup page with social login buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // 소셜 로그인 버튼들이 존재하는지 확인
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // 위젯이 정상적으로 렌더링되는지 확인
      expect(find.byType(SignupPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
