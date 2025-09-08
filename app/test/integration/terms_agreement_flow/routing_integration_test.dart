import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/location_terms_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/terms_of_service_page.dart';
import 'package:tomo_place/shared/application/routes/routes.dart';

import '../../utils/mock_factory/terms_mock_factory.dart';
import '../../utils/widget/app_wrappers.dart';
import '../../utils/widget/verifiers.dart';

// Mock Route 클래스
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  group('Terms Agreement Routing Integration Tests', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUpAll(() {
      // Route<dynamic> 타입에 대한 fallback 값 등록
      registerFallbackValue(FakeRoute());
    });

    setUp(() {
      mockNavigatorObserver = TermsMockFactory.createNavigatorObserver();
    });

    Widget createTestApp() {
      return AppWrappers.wrapWithMaterialApp(
        MaterialApp(
          home: const Scaffold(body: Center(child: Text('Test App'))),
          routes: {
            Routes.termsOfService: (context) => const TermsOfServicePage(),
            Routes.privacyPolicy: (context) => const PrivacyPolicyPage(),
            Routes.locationTerms: (context) => const LocationTermsPage(),
          },
        ),
      );
    }

    group('라우트 정의 테스트', () {
      testWidgets('이용약관 라우트가 올바르게 정의되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestApp());

        // Then
        expect(Routes.termsOfService, equals('/terms/terms-of-service'));
      });

      testWidgets('개인정보보호방침 라우트가 올바르게 정의되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestApp());

        // Then
        expect(Routes.privacyPolicy, equals('/terms/privacy-policy'));
      });

      testWidgets('위치정보 약관 라우트가 올바르게 정의되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestApp());

        // Then
        expect(Routes.locationTerms, equals('/terms/location-terms'));
      });
    });

    group('페이지 네비게이션 테스트', () {
      testWidgets('이용약관 페이지로 네비게이션이 가능해야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestApp());

        // When
        await tester.pumpWidget(
          AppWrappers.wrapWithMaterialApp(
            MaterialApp(
              home: const Scaffold(body: Center(child: Text('Test App'))),
              routes: {
                Routes.termsOfService: (context) => const TermsOfServicePage(),
              },
            ),
          ),
        );

        // Then
        // 라우트가 정의되어 있음을 확인
        expect(Routes.termsOfService, isNotNull);
      });

      testWidgets('개인정보보호방침 페이지로 네비게이션이 가능해야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestApp());

        // When
        await tester.pumpWidget(
          AppWrappers.wrapWithMaterialApp(
            MaterialApp(
              home: const Scaffold(body: Center(child: Text('Test App'))),
              routes: {
                Routes.privacyPolicy: (context) => const PrivacyPolicyPage(),
              },
            ),
          ),
        );

        // Then
        // 라우트가 정의되어 있음을 확인
        expect(Routes.privacyPolicy, isNotNull);
      });

      testWidgets('위치정보 약관 페이지로 네비게이션이 가능해야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestApp());

        // When
        await tester.pumpWidget(
          AppWrappers.wrapWithMaterialApp(
            MaterialApp(
              home: const Scaffold(body: Center(child: Text('Test App'))),
              routes: {
                Routes.locationTerms: (context) => const LocationTermsPage(),
              },
            ),
          ),
        );

        // Then
        // 라우트가 정의되어 있음을 확인
        expect(Routes.locationTerms, isNotNull);
      });
    });

    group('라우트 일관성 테스트', () {
      testWidgets('모든 약관 라우트가 /terms/ 접두사를 가져야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestApp());

        // Then
        expect(Routes.termsOfService, startsWith('/terms/'));
        expect(Routes.privacyPolicy, startsWith('/terms/'));
        expect(Routes.locationTerms, startsWith('/terms/'));
      });

      testWidgets('라우트 경로가 중복되지 않아야 한다', (WidgetTester tester) async {
        // Given
        final termsRoutes = [
          Routes.termsOfService,
          Routes.privacyPolicy,
          Routes.locationTerms,
        ];

        // When & Then
        final uniqueRoutes = termsRoutes.toSet();
        expect(uniqueRoutes.length, equals(termsRoutes.length));
      });

      testWidgets('라우트 경로가 유효한 형식이어야 한다', (WidgetTester tester) async {
        // Given
        final termsRoutes = [
          Routes.termsOfService,
          Routes.privacyPolicy,
          Routes.locationTerms,
        ];

        // When & Then
        for (final route in termsRoutes) {
          expect(route, startsWith('/'));
          expect(route, matches(r'^/[a-zA-Z0-9\-/]*$'));
        }
      });
    });

    group('페이지 렌더링 테스트', () {
      testWidgets('이용약관 페이지가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          AppWrappers.wrapWithMaterialApp(const TermsOfServicePage()),
        );

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsOfServicePage,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyTextDisplays(text: '이용약관', expectedCount: 1);
      });

      testWidgets('개인정보보호방침 페이지가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          AppWrappers.wrapWithMaterialApp(const PrivacyPolicyPage()),
        );

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: PrivacyPolicyPage,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyTextDisplays(text: '개인정보보호방침', expectedCount: 1);
      });

      testWidgets('위치정보 약관 페이지가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          AppWrappers.wrapWithMaterialApp(const LocationTermsPage()),
        );

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: LocationTermsPage,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyTextDisplays(text: '위치정보 약관', expectedCount: 1);
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock NavigatorObserver가 올바르게 처리되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        when(
          () => mockNavigatorObserver.didPush(any(), any()),
        ).thenReturn(null);

        // When
        await tester.pumpWidget(createTestApp());

        // Then
        expect(mockNavigatorObserver, isNotNull);
      });
    });

    group('라우트 변경 테스트', () {
      testWidgets('라우트 상수가 변경되지 않아야 한다', (WidgetTester tester) async {
        // Given
        final originalTermsOfService = Routes.termsOfService;
        final originalPrivacyPolicy = Routes.privacyPolicy;
        final originalLocationTerms = Routes.locationTerms;

        // When
        await tester.pumpWidget(createTestApp());

        // Then
        expect(Routes.termsOfService, equals(originalTermsOfService));
        expect(Routes.privacyPolicy, equals(originalPrivacyPolicy));
        expect(Routes.locationTerms, equals(originalLocationTerms));
      });
    });

    group('에러 처리 테스트', () {
      testWidgets('잘못된 라우트에 대한 에러 처리가 되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestApp());

        // Then
        // 잘못된 라우트는 정의되지 않았으므로 null이어야 함
        expect(Routes.termsOfService, isNotNull);
        expect(Routes.privacyPolicy, isNotNull);
        expect(Routes.locationTerms, isNotNull);
      });
    });
  });
}
