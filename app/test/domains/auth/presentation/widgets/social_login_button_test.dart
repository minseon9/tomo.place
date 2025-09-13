import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

void main() {
  group('SocialLoginButton', () {
    late VoidCallback mockOnPressed;

    setUp(() {
      mockOnPressed = () {};
    });

    Widget createWidget({
      required SocialProvider provider,
      VoidCallback? onPressed,
      bool isLoading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SocialLoginButton(
            provider: provider,
            onPressed: onPressed,
            isLoading: isLoading,
          ),
        ),
      );
    }

    group('레이아웃 구조', () {
      testWidgets('Container 위젯들이 존재해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        // Container 위젯들이 존재하는지 확인
        final containers = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(Container),
        );

        expect(containers, findsAtLeastNWidgets(1));
      });

      testWidgets('Padding 위젯이 존재해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        // Padding 위젯이 존재하는지 확인
        final padding = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(Padding),
        );

        expect(padding, findsAtLeastNWidgets(1));
      });

      testWidgets('SizedBox 위젯들이 존재해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        // SizedBox 위젯들이 존재하는지 확인
        final sizedBoxes = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(SizedBox),
        );

        expect(sizedBoxes, findsAtLeastNWidgets(1));
      });

      testWidgets('Google 버튼에 텍스트가 올바르게 렌더링되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        expect(find.text('구글로 시작하기'), findsOneWidget);
      });

      testWidgets('Apple 버튼에 텍스트가 올바르게 렌더링되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.apple,
            onPressed: mockOnPressed,
          ),
        );

        expect(find.text('애플로 시작하기 (준비 중)'), findsOneWidget);
      });

      testWidgets('Kakao 버튼에 텍스트가 올바르게 렌더링되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        expect(find.text('카카오로 시작하기 (준비 중)'), findsOneWidget);
      });

      testWidgets('Kakao 버튼이 disabled 상태에서 올바른 배경색이 적용되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        // SocialLoginButton 내부의 모든 Container를 찾아서 decoration이 있는 것 찾기
        final containers = find.descendant(
          of: find.byType(SocialLoginButton),
          matching: find.byType(Container),
        );
        
        bool foundDecoration = false;
        for (int i = 0; i < containers.evaluate().length; i++) {
          final container = containers.at(i);
          final containerWidget = tester.widget<Container>(container);
          final decoration = containerWidget.decoration;
          
          if (decoration != null && decoration is BoxDecoration) {
            // Disabled 상태에서는 투명한 회색이어야 함
            expect(decoration.color, equals(AppColors.tomoDarkGray.withValues(alpha: 0.3)));
            foundDecoration = true;
            break;
          }
        }
        
        // decoration이 있는 Container가 있어야 함
        expect(foundDecoration, isTrue);
      });

      testWidgets('Apple 버튼이 disabled 상태에서 올바른 텍스트 스타일이 적용되어야 한다', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.apple,
            onPressed: mockOnPressed,
          ),
        );

        // Apple 버튼이 disabled 상태에서 텍스트 스타일 확인
        final text = find.text('애플로 시작하기 (준비 중)');
        expect(text, findsOneWidget);
        
        final textWidget = tester.widget<Text>(text);
        // Disabled 상태에서는 회색 텍스트여야 함
        expect(textWidget.style?.color, equals(AppColors.tomoDarkGray.withValues(alpha: 0.5)));
      });
    });

    group('기존 로직 보존', () {
      testWidgets('Google 버튼은 활성화 상태', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNotNull);
      });

      testWidgets('Kakao 버튼은 비활성화 상태', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNull);
      });

      testWidgets('Apple 버튼은 비활성화 상태', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.apple,
            onPressed: mockOnPressed,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNull);
      });

      testWidgets('로딩 상태에서 버튼 비활성화', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
            isLoading: true,
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(SocialLoginButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.onTap, isNull);
      });

      testWidgets('올바른 텍스트 표시', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        expect(find.text('구글로 시작하기'), findsOneWidget);
      });

      testWidgets('비활성화 상태에서 올바른 텍스트 표시', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        expect(find.text('카카오로 시작하기 (준비 중)'), findsOneWidget);
      });

      testWidgets('올바른 배경색 적용', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SocialLoginButton),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration;
        if (decoration != null) {
          expect(decoration, isA<BoxDecoration>());
          if (decoration is BoxDecoration) {
            expect(decoration.color, equals(AppColors.white));
          }
        }
      });

      testWidgets('비활성화 상태에서 올바른 배경색 적용', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.kakao,
            onPressed: mockOnPressed,
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SocialLoginButton),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration;
        if (decoration != null) {
          expect(decoration, isA<BoxDecoration>());
          if (decoration is BoxDecoration) {
            expect(
              decoration.color,
              equals(AppColors.tomoDarkGray.withValues(alpha: 0.3)),
            );
          }
        }
      });
    });

    group('위젯 트리 구조 검증', () {
      testWidgets('올바른 위젯 계층 구조', (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidget(
            provider: SocialProvider.google,
            onPressed: mockOnPressed,
          ),
        );

        // SocialLoginButton -> Container -> Material -> InkWell -> Padding -> Row
        expect(find.byType(SocialLoginButton), findsOneWidget);
        expect(
          find.byType(Container),
          findsAtLeastNWidgets(1),
        ); // ResponsiveContainer의 Container + 버튼 Container
        expect(
          find.byType(Material),
          findsAtLeastNWidgets(1),
        ); // MaterialApp + 버튼 내부 Material
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        expect(
          find.byType(SizedBox),
          findsAtLeastNWidgets(2),
        ); // 아이콘 SizedBox + 간격 SizedBox
      });
    });
  });
}
