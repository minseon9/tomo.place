import 'package:tomo_place/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter', () {
    group('generateRoute', () {
      test('splash 라우트가 올바르게 생성되어야 한다', () {
        // Given
        const settings = RouteSettings(name: '/splash');

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('home 라우트가 올바르게 생성되어야 한다', () {
        // Given
        const settings = RouteSettings(name: '/home');

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('signup 라우트가 올바르게 생성되어야 한다', () {
        // Given
        const settings = RouteSettings(name: '/signup');

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });
    });

    group('404 처리', () {
      test('존재하지 않는 라우트에 대해 404 페이지를 반환해야 한다', () {
        // Given
        const settings = RouteSettings(name: '/nonexistent');

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('null 라우트 이름에 대해 404 페이지를 반환해야 한다', () {
        // Given
        const settings = RouteSettings(name: null);

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('빈 라우트 이름에 대해 404 페이지를 반환해야 한다', () {
        // Given
        const settings = RouteSettings(name: '');

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });
    });

    group('라우트 설정', () {
      test('라우트 설정이 올바르게 전달되어야 한다', () {
        // Given
        const settings = RouteSettings(
          name: '/splash',
          arguments: {'test': 'value'},
        );

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route.settings, equals(settings));
        expect(route.settings.name, equals('/splash'));
        expect(route.settings.arguments, equals({'test': 'value'}));
      });

      test('라우트 이름이 올바르게 설정되어야 한다', () {
        // Given
        const settings = RouteSettings(name: '/home');

        // When
        final route = AppRouter.generateRoute(settings);

        // Then
        expect(route.settings.name, equals('/home'));
      });
    });

    group('라우트 타입', () {
      test('모든 라우트가 MaterialPageRoute 타입이어야 한다', () {
        // Given
        final testRoutes = ['/splash', '/home', '/signup', '/nonexistent'];

        for (final routeName in testRoutes) {
          // When
          final route = AppRouter.generateRoute(RouteSettings(name: routeName));

          // Then
          expect(route, isA<MaterialPageRoute>(), reason: 'Route $routeName should be MaterialPageRoute');
        }
      });

      test('MaterialPageRoute의 설정이 올바르게 전달되어야 한다', () {
        // Given
        const settings = RouteSettings(name: '/splash');
        final route = AppRouter.generateRoute(settings) as MaterialPageRoute;

        // When & Then
        expect(route.settings, equals(settings));
        expect(route.settings.name, equals('/splash'));
      });
    });

    group('라우트 매핑', () {
      test('지원되는 모든 라우트가 올바르게 매핑되어야 한다', () {
        // Given
        final supportedRoutes = ['/splash', '/home', '/signup'];

        for (final routeName in supportedRoutes) {
          // When
          final route = AppRouter.generateRoute(RouteSettings(name: routeName));

          // Then
          expect(route, isA<MaterialPageRoute>());
          expect(route.settings.name, equals(routeName));
        }
      });

      test('지원되지 않는 라우트는 404로 처리되어야 한다', () {
        // Given
        final unsupportedRoutes = ['/admin', '/profile', '/settings'];

        for (final routeName in unsupportedRoutes) {
          // When
          final route = AppRouter.generateRoute(RouteSettings(name: routeName));

          // Then
          expect(route, isA<MaterialPageRoute>());
          expect(route.settings.name, equals(routeName));
        }
      });
    });
  });
}
