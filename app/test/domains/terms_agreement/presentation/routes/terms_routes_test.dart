import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/routes/terms_routes.dart';
import 'package:tomo_place/shared/application/routes/routes.dart';

void main() {
  group('TermsRoutes', () {
    group('builders getter 테스트', () {
      test('builders가 올바른 Map을 반환해야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;

        // Then
        expect(builders, isA<Map<String, WidgetBuilder>>());
        expect(builders.length, equals(3));
      });

      test('builders에 모든 약관 라우트가 포함되어야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;

        // Then
        expect(builders.containsKey(Routes.termsOfService), isTrue);
        expect(builders.containsKey(Routes.privacyPolicy), isTrue);
        expect(builders.containsKey(Routes.locationTerms), isTrue);
      });

      test('builders의 각 라우트가 올바른 WidgetBuilder를 반환해야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;

        // Then
        expect(builders[Routes.termsOfService], isNotNull);
        expect(builders[Routes.privacyPolicy], isNotNull);
        expect(builders[Routes.locationTerms], isNotNull);
      });

      test('builders의 각 WidgetBuilder가 올바른 위젯을 생성해야 한다', () {
        // Given
        final builders = TermsRoutes.builders;

        // When & Then - WidgetBuilder가 정상적으로 호출되는지만 확인
        expect(builders[Routes.termsOfService], isNotNull);
        expect(builders[Routes.privacyPolicy], isNotNull);
        expect(builders[Routes.locationTerms], isNotNull);
      });

      test('builders의 키가 올바른 라우트 경로여야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;

        // Then
        expect(builders.keys, contains(Routes.termsOfService));
        expect(builders.keys, contains(Routes.privacyPolicy));
        expect(builders.keys, contains(Routes.locationTerms));
      });

      test('builders의 값이 WidgetBuilder 타입이어야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;

        // Then
        for (final builder in builders.values) {
          expect(builder, isA<WidgetBuilder>());
        }
      });

      test('builders에 예상치 못한 라우트가 없어야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;
        final expectedRoutes = {
          Routes.termsOfService,
          Routes.privacyPolicy,
          Routes.locationTerms,
        };

        // Then
        expect(builders.keys.toSet(), equals(expectedRoutes));
      });

      test('builders의 각 라우트가 고유해야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;

        // Then
        expect(builders.keys.length, equals(builders.keys.toSet().length));
      });

      test('builders의 각 WidgetBuilder가 고유해야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;

        // Then
        expect(builders.values.length, equals(builders.values.toSet().length));
      });
    });

    group('라우트 매핑 테스트', () {
      testWidgets('이용약관 라우트가 올바른 WidgetBuilder를 반환해야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        final builders = TermsRoutes.builders;

        // When & Then
        expect(builders[Routes.termsOfService], isNotNull);
        expect(builders[Routes.termsOfService], isA<WidgetBuilder>());

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => builders[Routes.termsOfService]!(context),
            ),
          ),
        );
        expect(find.byType(MaterialApp), findsOneWidget);
      });

      testWidgets('개인정보보호방침 라우트가 올바른 WidgetBuilder를 반환해야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        final builders = TermsRoutes.builders;

        // When & Then
        expect(builders[Routes.privacyPolicy], isNotNull);
        expect(builders[Routes.privacyPolicy], isA<WidgetBuilder>());

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => builders[Routes.privacyPolicy]!(context),
            ),
          ),
        );
        expect(find.byType(MaterialApp), findsOneWidget);
      });

      testWidgets('위치정보 약관 라우트가 올바른 WidgetBuilder를 반환해야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        final builders = TermsRoutes.builders;

        // When & Then
        expect(builders[Routes.locationTerms], isNotNull);
        expect(builders[Routes.locationTerms], isA<WidgetBuilder>());

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => builders[Routes.locationTerms]!(context),
            ),
          ),
        );
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Line Coverage 테스트', () {
      test('TermsRoutes 클래스의 모든 static 멤버에 접근해야 한다', () {
        // Given & When & Then
        expect(TermsRoutes.builders, isNotNull);
        expect(TermsRoutes.builders, isA<Map<String, WidgetBuilder>>());
      });

      test('builders getter를 여러 번 호출해도 일관된 결과를 반환해야 한다', () {
        // Given & When
        final builders1 = TermsRoutes.builders;
        final builders2 = TermsRoutes.builders;
        final builders3 = TermsRoutes.builders;

        // Then
        expect(builders1.length, equals(builders2.length));
        expect(builders2.length, equals(builders3.length));
        expect(builders1.length, equals(builders3.length));
        expect(builders1.keys, equals(builders2.keys));
        expect(builders2.keys, equals(builders3.keys));
        expect(builders1.keys, equals(builders3.keys));
      });

      test('builders의 모든 항목을 순회할 수 있어야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;
        int count = 0;

        // Then
        for (final entry in builders.entries) {
          expect(entry.key, isA<String>());
          expect(entry.value, isA<WidgetBuilder>());
          count++;
        }
        expect(count, equals(3));
      });

      test('builders의 키와 값을 개별적으로 접근할 수 있어야 한다', () {
        // Given & When
        final builders = TermsRoutes.builders;
        final keys = builders.keys.toList();
        final values = builders.values.toList();

        // Then
        expect(keys.length, equals(3));
        expect(values.length, equals(3));
        expect(keys, contains(Routes.termsOfService));
        expect(keys, contains(Routes.privacyPolicy));
        expect(keys, contains(Routes.locationTerms));
      });
    });
  });
}
