import 'package:tomo_place/app/pages/splash_page.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/mock_factory/presentation_mock_factory.dart';

void main() {
  group('SplashPage', () {
    // Mock 객체들
    late MockAuthNotifier mockAuthNotifier;
    late MockAuthState mockAuthState;
    late MockExceptionInterface mockExceptionInterface;

    setUp(() {
      // Mock 객체들 생성
      mockAuthNotifier = PresentationMockFactory.createAuthNotifier();
      mockAuthState = PresentationMockFactory.createAuthState();
      mockExceptionInterface = PresentationMockFactory.createExceptionInterface();

      // Register fallback values
      registerFallbackValue(true);
      registerFallbackValue(AuthInitial());
      registerFallbackValue(AuthSuccess(true));
      registerFallbackValue(AuthFailure(error: mockExceptionInterface));

      // Mock 기본 설정
      when(() => mockAuthNotifier.state).thenReturn(mockAuthState);
      when(() => mockAuthNotifier.refreshToken(any())).thenAnswer((_) async => null);
      when(() => mockAuthNotifier.addListener(any())).thenReturn(() {});
    });

    tearDown(() {
      // Mock 상태 초기화
      reset(mockAuthNotifier);
      reset(mockAuthState);
      reset(mockExceptionInterface);
    });

    // Helper 함수들
    Widget createTestSplashPage({List<Override> overrides = const []}) {
      return MaterialApp(
        home: ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            ...overrides,
          ],
          child: const SplashPage(), // 실제 SplashPage 사용
        ),
      );
    }

    void setupMockAuthState(AuthState state) {
      when(() => mockAuthNotifier.state).thenReturn(state);
    }

    void setupMockRefreshToken({bool shouldThrow = false, Exception? exception}) {
      if (shouldThrow && exception != null) {
        when(() => mockAuthNotifier.refreshToken(any())).thenThrow(exception);
      } else {
        when(() => mockAuthNotifier.refreshToken(any())).thenAnswer((_) async => null);
      }
    }

    void verifyRefreshTokenCalled(bool expected) {
      if (expected) {
        verify(() => mockAuthNotifier.refreshToken(true)).called(1);
      } else {
        verifyNever(() => mockAuthNotifier.refreshToken(any()));
      }
    }

    void verifyUIElements(WidgetTester tester) {
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    }

    // 테스트 그룹들
    group('Provider 테스트', () {
      testWidgets('ProviderScope가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestSplashPage());

        // When & Then
        // ProviderScope가 존재하는지 확인
        expect(find.byType(ProviderScope), findsOneWidget);
        expect(find.byType(SplashPage), findsOneWidget);
      });

      testWidgets('SplashPage가 ProviderScope 내에서 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestSplashPage());

        // When & Then
        // SplashPage가 ProviderScope 내에서 올바르게 렌더링되는지 확인
        expect(find.byType(SplashPage), findsOneWidget);
        verifyUIElements(tester);
      });
    });

    group('생명주기 테스트', () {
      testWidgets('SplashPage가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        expect(find.byType(SplashPage), findsOneWidget);
        verifyUIElements(tester);
      });

      testWidgets('위젯이 안정적으로 마운트되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());
        
        // 여러 번의 pump로 안정성 확인
        await tester.pump();
        await tester.pump();

        // Then
        expect(find.byType(SplashPage), findsOneWidget);
        verifyUIElements(tester);
      });
    });

    group('인증 상태 확인 테스트', () {
      testWidgets('SplashPage가 인증 상태와 관계없이 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        verifyUIElements(tester);
      });

      testWidgets('인증 성공 상태에서 UI가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockAuthState(AuthSuccess(true));
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        verifyUIElements(tester);
      });

      testWidgets('인증 실패 상태에서 UI가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockAuthState(AuthFailure(error: mockExceptionInterface));
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        verifyUIElements(tester);
      });

      testWidgets('네트워크 에러 상태에서 UI가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken(shouldThrow: true, exception: Exception('Network error'));

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        verifyUIElements(tester);
      });
    });

    group('UI 렌더링 테스트', () {
      testWidgets('CircularProgressIndicator가 표시되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Scaffold 구조가 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
      });

      testWidgets('Center 위젯이 올바르게 배치되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        final center = tester.widget<Center>(find.byType(Center));
        expect(center.child, isA<CircularProgressIndicator>());
      });
    });

    group('Timer 문제 해결 테스트', () {
      testWidgets('SplashPage로 Timer 문제를 해결해야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        // Timer 문제 없이 UI가 렌더링되는지 확인
        verifyUIElements(tester);
      });

      testWidgets('pump 조합으로 안정적인 렌더링을 보장해야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());
        
        // 여러 번의 pump로 안정성 확인
        await tester.pump();
        await tester.pump();
        await tester.pump();

        // Then
        verifyUIElements(tester);
      });

      testWidgets('pumpAndSettle 없이도 정상 동작해야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());
        
        // pumpAndSettle 대신 pump만 사용
        await tester.pump();

        // Then
        verifyUIElements(tester);
      });
    });

    group('에러 처리 테스트', () {
      testWidgets('인증 에러 상태에서 UI가 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken(shouldThrow: true, exception: Exception('Auth error'));

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        // 에러가 발생해도 UI는 여전히 렌더링되어야 함
        verifyUIElements(tester);
      });

      testWidgets('네트워크 에러 상태에서 UI가 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken(shouldThrow: true, exception: Exception('Network error'));

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        // 네트워크 에러가 발생해도 UI는 여전히 렌더링되어야 함
        verifyUIElements(tester);
      });

      testWidgets('타임아웃 에러 상태에서 UI가 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockRefreshToken(shouldThrow: true, exception: Exception('Timeout'));

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        // 타임아웃 에러가 발생해도 UI는 여전히 렌더링되어야 함
        verifyUIElements(tester);
      });
    });

    group('통합 테스트', () {
      testWidgets('전체 SplashPage 플로우가 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given
        setupMockAuthState(AuthInitial());
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        // 1. UI가 올바르게 렌더링되는지
        verifyUIElements(tester);
        
        // 2. ProviderScope가 올바르게 설정되어 있는지
        expect(find.byType(ProviderScope), findsOneWidget);
      });

      testWidgets('여러 상태에서 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        setupMockAuthState(AuthInitial());
        setupMockRefreshToken();

        // When
        await tester.pumpWidget(createTestSplashPage());

        // Then
        // UI가 안정적으로 렌더링되는지 확인
        verifyUIElements(tester);
        
        // 위젯이 여전히 안정적으로 렌더링되는지 확인
        expect(find.byType(SplashPage), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}
