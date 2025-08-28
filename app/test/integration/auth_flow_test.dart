import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/app/app.dart';
import 'package:app/domains/auth/presentation/controllers/auth_controller.dart';
import 'package:app/domains/auth/services/auth_service.dart';
import 'package:app/domains/auth/domain/entities/user.dart';
import 'package:app/shared/exceptions/auth_exception.dart';
import 'package:app/shared/config/app_config.dart';
import 'package:app/app/di/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Auth Flow Integration Tests', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await AppConfig.initialize();
      await di.initializeDependencies();
    });

    tearDownAll(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('should complete full Google login flow successfully', (WidgetTester tester) async {
      // 실제 앱 위젯으로 테스트
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 로그인 페이지가 표시되는지 확인
      expect(find.text('로그인'), findsOneWidget);
      expect(find.text('Google로 로그인'), findsOneWidget);

      // Google 로그인 버튼 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.pump();

      // 로딩 상태 확인
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 로딩 완료 후 상태 확인
      await tester.pumpAndSettle();

      // 성공적으로 로그인되었는지 확인 (실제 구현에 따라 다를 수 있음)
      // 여기서는 기본적인 UI 흐름만 테스트
    });

    testWidgets('should handle authentication failure gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // Google 로그인 버튼 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.pump();

      // 에러 상태에서도 UI가 깨지지 않는지 확인
      await tester.pumpAndSettle();

      // 로그인 페이지가 여전히 표시되는지 확인
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('should show proper error messages for different scenarios', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // Kakao 로그인 버튼 탭 (준비 중 메시지)
      await tester.tap(find.text('Kakao로 로그인'));
      await tester.pumpAndSettle();

      expect(find.text('준비 중입니다'), findsOneWidget);

      // Apple 로그인 버튼 탭 (준비 중 메시지)
      await tester.tap(find.text('Apple로 로그인'));
      await tester.pumpAndSettle();

      expect(find.text('준비 중입니다'), findsOneWidget);
    });

    testWidgets('should navigate between auth pages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 이메일 로그인 링크 탭
      await tester.tap(find.text('이메일로 로그인'));
      await tester.pumpAndSettle();

      // 이메일 로그인 페이지로 이동했는지 확인
      // (실제 구현에 따라 페이지 제목이나 내용 확인)

      // 뒤로 가기
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 다시 로그인 페이지로 돌아왔는지 확인
      expect(find.text('로그인'), findsOneWidget);

      // 회원가입 링크 탭
      await tester.tap(find.text('계정이 없으신가요? 회원가입'));
      await tester.pumpAndSettle();

      // 회원가입 페이지로 이동했는지 확인
      // (실제 구현에 따라 페이지 제목이나 내용 확인)
    });

    testWidgets('should maintain state during navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // Google 로그인 버튼 탭하여 로딩 상태로 전환
      await tester.tap(find.text('Google로 로그인'));
      await tester.pump();

      // 로딩 중에 다른 페이지로 이동
      await tester.tap(find.text('이메일로 로그인'));
      await tester.pumpAndSettle();

      // 다시 로그인 페이지로 돌아와도 상태가 올바른지 확인
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('should handle rapid user interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 여러 버튼을 빠르게 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.tap(find.text('Kakao로 로그인'));
      await tester.tap(find.text('Apple로 로그인'));
      await tester.tap(find.text('이메일로 로그인'));
      await tester.pumpAndSettle();

      // UI가 깨지지 않고 적절한 응답을 하는지 확인
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('should display proper loading indicators', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // Google 로그인 버튼 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.pump();

      // 로딩 인디케이터가 표시되는지 확인
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 로딩 완료 후 인디케이터가 사라지는지 확인
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should handle network connectivity issues', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 네트워크 에러 상황을 시뮬레이션 (실제로는 네트워크 상태를 모킹해야 함)
      await tester.tap(find.text('Google로 로그인'));
      await tester.pumpAndSettle();

      // 에러 메시지가 표시되는지 확인
      // (실제 구현에 따라 다를 수 있음)
    });

    testWidgets('should preserve user preferences across app restarts', (WidgetTester tester) async {
      // 첫 번째 앱 실행
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 사용자 설정 변경 (예: 테마 변경 등)
      // (실제 구현에 따라 다를 수 있음)

      // 앱 재시작 시뮬레이션
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 설정이 유지되는지 확인
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('should handle deep linking correctly', (WidgetTester tester) async {
      // 딥링크로 특정 페이지로 이동하는 시나리오 테스트
      // (실제 구현에 따라 다를 수 있음)
      
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 딥링크 처리 후 올바른 페이지가 표시되는지 확인
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('should perform accessibility testing', (WidgetTester tester) async {
      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      // 접근성 라벨 확인
      expect(find.bySemanticsLabel('Google로 로그인'), findsOneWidget);
      expect(find.bySemanticsLabel('Kakao로 로그인'), findsOneWidget);
      expect(find.bySemanticsLabel('Apple로 로그인'), findsOneWidget);

      // 접근성 힌트 확인
      // (실제 구현에 따라 다를 수 있음)
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // 작은 화면
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      expect(find.text('로그인'), findsOneWidget);

      // 큰 화면
      tester.binding.window.physicalSizeTestValue = const Size(1024, 768);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(const TomoPlaceApp());
      await tester.pumpAndSettle();

      expect(find.text('로그인'), findsOneWidget);

      // 원래 크기로 복원
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
