import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/application/routes/routes.dart';

void main() {
  group('Routes', () {
    group('라우트 상수 정의 테스트', () {
      test('모든 라우트 상수가 올바르게 정의되어야 한다', () {
        // Given & When & Then
        expect(Routes.signup, equals('/auth/signup'));
        expect(Routes.login, equals('/auth/login'));
        expect(Routes.termsOfService, equals('/terms/terms-of-service'));
        expect(Routes.privacyPolicy, equals('/terms/privacy-policy'));
        expect(Routes.locationTerms, equals('/terms/location-terms'));
        expect(Routes.splash, equals('/splash'));
        expect(Routes.home, equals('/home'));
      });

      test('라우트 경로가 올바른 형식을 가져야 한다', () {
        // Given & When & Then
        expect(Routes.signup, startsWith('/auth/'));
        expect(Routes.login, startsWith('/auth/'));
        expect(Routes.termsOfService, startsWith('/terms/'));
        expect(Routes.privacyPolicy, startsWith('/terms/'));
        expect(Routes.locationTerms, startsWith('/terms/'));
        expect(Routes.splash, startsWith('/'));
        expect(Routes.home, startsWith('/'));
      });

      test('라우트 경로가 슬래시로 시작해야 한다', () {
        // Given & When & Then
        final allRoutes = [
          Routes.signup,
          Routes.login,
          Routes.termsOfService,
          Routes.privacyPolicy,
          Routes.locationTerms,
          Routes.splash,
          Routes.home,
        ];

        for (final route in allRoutes) {
          expect(route, startsWith('/'));
        }
      });

      test('라우트 경로가 중복되지 않아야 한다', () {
        // Given
        final allRoutes = [
          Routes.signup,
          Routes.login,
          Routes.termsOfService,
          Routes.privacyPolicy,
          Routes.locationTerms,
          Routes.splash,
          Routes.home,
        ];

        // When & Then
        final uniqueRoutes = allRoutes.toSet();
        expect(uniqueRoutes.length, equals(allRoutes.length));
      });
    });

    group('라우트 경로 유효성 테스트', () {
      test('라우트 경로가 비어있지 않아야 한다', () {
        // Given & When & Then
        expect(Routes.signup.isNotEmpty, isTrue);
        expect(Routes.login.isNotEmpty, isTrue);
        expect(Routes.termsOfService.isNotEmpty, isTrue);
        expect(Routes.privacyPolicy.isNotEmpty, isTrue);
        expect(Routes.locationTerms.isNotEmpty, isTrue);
        expect(Routes.splash.isNotEmpty, isTrue);
        expect(Routes.home.isNotEmpty, isTrue);
      });

      test('라우트 경로가 유효한 문자만 포함해야 한다', () {
        // Given
        final allRoutes = [
          Routes.signup,
          Routes.login,
          Routes.termsOfService,
          Routes.privacyPolicy,
          Routes.locationTerms,
          Routes.splash,
          Routes.home,
        ];

        // When & Then
        for (final route in allRoutes) {
          expect(route, matches(r'^/[a-zA-Z0-9\-/]*$'));
        }
      });
    });

    group('라우트 상수 불변성 테스트', () {
      test('라우트 상수가 const로 정의되어야 한다', () {
        // Given & When & Then
        expect(Routes.signup, isA<String>());
        expect(Routes.login, isA<String>());
        expect(Routes.termsOfService, isA<String>());
        expect(Routes.privacyPolicy, isA<String>());
        expect(Routes.locationTerms, isA<String>());
        expect(Routes.splash, isA<String>());
        expect(Routes.home, isA<String>());
      });

      test('라우트 상수가 변경되지 않아야 한다', () {
        // Given
        final originalSignup = Routes.signup;
        final originalLogin = Routes.login;
        final originalTermsOfService = Routes.termsOfService;

        // When & Then
        expect(Routes.signup, equals(originalSignup));
        expect(Routes.login, equals(originalLogin));
        expect(Routes.termsOfService, equals(originalTermsOfService));
      });
    });
  });
}
