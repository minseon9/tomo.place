import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/typography.dart';

void main() {
  group('AppTypography', () {
    group('Header 스타일 테스트', () {
      testWidgets('header1 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Header 1', style: AppTypography.header1),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Header 1'));
        expect(text.style?.fontSize, equals(32));
        expect(text.style?.fontWeight, equals(FontWeight.w700));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('header2 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Header 2', style: AppTypography.header2),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Header 2'));
        expect(text.style?.fontSize, equals(24));
        expect(text.style?.fontWeight, equals(FontWeight.w600));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('header3 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Header 3', style: AppTypography.header3),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Header 3'));
        expect(text.style?.fontSize, equals(20));
        expect(text.style?.fontWeight, equals(FontWeight.w600));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.letterSpacing, equals(-0.4));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('head3 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Head 3', style: AppTypography.head3),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Head 3'));
        expect(text.style?.fontSize, equals(18));
        expect(text.style?.fontWeight, equals(FontWeight.w600));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.letterSpacing, equals(-0.2));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });
    });

    group('Body 스타일 테스트', () {
      testWidgets('body 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Body Text', style: AppTypography.body),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Body Text'));
        expect(text.style?.fontSize, equals(16));
        expect(text.style?.fontWeight, equals(FontWeight.w400));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });
    });

    group('Button 스타일 테스트', () {
      testWidgets('button 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Button Text', style: AppTypography.button),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Button Text'));
        expect(text.style?.fontSize, equals(14));
        expect(text.style?.fontWeight, equals(FontWeight.w500));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });
    });

    group('Caption 스타일 테스트', () {
      testWidgets('caption 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Caption Text', style: AppTypography.caption),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Caption Text'));
        expect(text.style?.fontSize, equals(12));
        expect(text.style?.fontWeight, equals(FontWeight.w400));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('bold 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Bold Text', style: AppTypography.bold),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Bold Text'));
        expect(text.style?.fontSize, equals(12));
        expect(text.style?.fontWeight, equals(FontWeight.w700));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });
    });

    group('Legacy 스타일 테스트', () {
      testWidgets('h1 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('H1 Text', style: AppTypography.h1),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('H1 Text'));
        expect(text.style?.fontSize, equals(32));
        expect(text.style?.fontWeight, equals(FontWeight.w700));
        expect(text.style?.height, equals(1.25));
        expect(text.style?.letterSpacing, equals(-0.5));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('h2 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('H2 Text', style: AppTypography.h2),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('H2 Text'));
        expect(text.style?.fontSize, equals(24));
        expect(text.style?.fontWeight, equals(FontWeight.w600));
        expect(text.style?.height, equals(1.3));
        expect(text.style?.letterSpacing, equals(-0.3));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('h3 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('H3 Text', style: AppTypography.h3),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('H3 Text'));
        expect(text.style?.fontSize, equals(20));
        expect(text.style?.fontWeight, equals(FontWeight.w600));
        expect(text.style?.height, equals(1.4));
        expect(text.style?.letterSpacing, equals(-0.2));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('bodyLarge 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Body Large', style: AppTypography.bodyLarge),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Body Large'));
        expect(text.style?.fontSize, equals(16));
        expect(text.style?.fontWeight, equals(FontWeight.w400));
        expect(text.style?.height, equals(1.5));
        expect(text.style?.letterSpacing, equals(0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('bodyMedium 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Body Medium', style: AppTypography.bodyMedium),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Body Medium'));
        expect(text.style?.fontSize, equals(14));
        expect(text.style?.fontWeight, equals(FontWeight.w400));
        expect(text.style?.height, equals(1.4));
        expect(text.style?.letterSpacing, equals(0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('bodySmall 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Body Small', style: AppTypography.bodySmall),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Body Small'));
        expect(text.style?.fontSize, equals(12));
        expect(text.style?.fontWeight, equals(FontWeight.w400));
        expect(text.style?.height, equals(1.3));
        expect(text.style?.letterSpacing, equals(0.1));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('buttonLarge 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Button Large', style: AppTypography.buttonLarge),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Button Large'));
        expect(text.style?.fontSize, equals(16));
        expect(text.style?.fontWeight, equals(FontWeight.w600));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.letterSpacing, equals(0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('buttonMedium 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Button Medium', style: AppTypography.buttonMedium),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Button Medium'));
        expect(text.style?.fontSize, equals(14));
        expect(text.style?.fontWeight, equals(FontWeight.w500));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.letterSpacing, equals(0));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });

      testWidgets('overline 스타일이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Overline', style: AppTypography.overline),
            ),
          ),
        );

        // Then
        final text = tester.widget<Text>(find.text('Overline'));
        expect(text.style?.fontSize, equals(10));
        expect(text.style?.fontWeight, equals(FontWeight.w500));
        expect(text.style?.height, equals(1.0));
        expect(text.style?.letterSpacing, equals(0.5));
        expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
      });
    });

    group('Line Coverage 테스트', () {
      testWidgets('AppTypography 생성자가 호출되어야 한다', (WidgetTester tester) async {
        // Given & When & Then
        // AppTypography._() 생성자를 호출하기 위해 인스턴스를 생성해보려고 시도
        // 하지만 private 생성자이므로 직접 호출할 수 없음
        // 대신 static 멤버에 접근하여 클래스가 로드되도록 함
        expect(AppTypography.header1, isNotNull);
        expect(AppTypography.header2, isNotNull);
        expect(AppTypography.header3, isNotNull);
        expect(AppTypography.head3, isNotNull);
        expect(AppTypography.body, isNotNull);
        expect(AppTypography.button, isNotNull);
        expect(AppTypography.caption, isNotNull);
        expect(AppTypography.bold, isNotNull);
        expect(AppTypography.h1, isNotNull);
        expect(AppTypography.h2, isNotNull);
        expect(AppTypography.h3, isNotNull);
        expect(AppTypography.bodyLarge, isNotNull);
        expect(AppTypography.bodyMedium, isNotNull);
        expect(AppTypography.bodySmall, isNotNull);
        expect(AppTypography.buttonLarge, isNotNull);
        expect(AppTypography.buttonMedium, isNotNull);
        expect(AppTypography.overline, isNotNull);
      });

      testWidgets('모든 스타일이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Header 1', style: AppTypography.header1),
                  Text('Header 2', style: AppTypography.header2),
                  Text('Header 3', style: AppTypography.header3),
                  Text('Head 3', style: AppTypography.head3),
                  Text('Body', style: AppTypography.body),
                  Text('Button', style: AppTypography.button),
                  Text('Caption', style: AppTypography.caption),
                  Text('Bold', style: AppTypography.bold),
                  Text('H1', style: AppTypography.h1),
                  Text('H2', style: AppTypography.h2),
                  Text('H3', style: AppTypography.h3),
                  Text('Body Large', style: AppTypography.bodyLarge),
                  Text('Body Medium', style: AppTypography.bodyMedium),
                  Text('Body Small', style: AppTypography.bodySmall),
                  Text('Button Large', style: AppTypography.buttonLarge),
                  Text('Button Medium', style: AppTypography.buttonMedium),
                  Text('Overline', style: AppTypography.overline),
                ],
              ),
            ),
          ),
        );

        // Then
        expect(find.text('Header 1'), findsOneWidget);
        expect(find.text('Header 2'), findsOneWidget);
        expect(find.text('Header 3'), findsOneWidget);
        expect(find.text('Head 3'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);
        expect(find.text('Button'), findsOneWidget);
        expect(find.text('Caption'), findsOneWidget);
        expect(find.text('Bold'), findsOneWidget);
        expect(find.text('H1'), findsOneWidget);
        expect(find.text('H2'), findsOneWidget);
        expect(find.text('H3'), findsOneWidget);
        expect(find.text('Body Large'), findsOneWidget);
        expect(find.text('Body Medium'), findsOneWidget);
        expect(find.text('Body Small'), findsOneWidget);
        expect(find.text('Button Large'), findsOneWidget);
        expect(find.text('Button Medium'), findsOneWidget);
        expect(find.text('Overline'), findsOneWidget);
      });

      testWidgets('모든 스타일의 fontFamily가 일관되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Test 1', style: AppTypography.header1),
                  Text('Test 2', style: AppTypography.body),
                  Text('Test 3', style: AppTypography.button),
                  Text('Test 4', style: AppTypography.caption),
                ],
              ),
            ),
          ),
        );

        // Then
        final texts = find.byType(Text);
        for (int i = 0; i < texts.evaluate().length; i++) {
          final text = tester.widget<Text>(texts.at(i));
          expect(text.style?.fontFamily, equals('Apple SD Gothic Neo'));
        }
      });
    });
  });
}