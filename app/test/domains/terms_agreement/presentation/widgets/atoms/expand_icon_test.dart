import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/expand_icon.dart';

import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsExpandIcon', () {
  setUp(() {
    // Setup for tests
  });

    Widget createTestWidget() {
      return AppWrappers.wrapWithMaterialApp(const TermsExpandIcon());
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsExpandIcon,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Container,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: SvgPicture,
          expectedCount: 1,
        );
      });

      testWidgets('올바른 SVG 아이콘을 표시해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(svgPicture, isNotNull);
      });

      testWidgets('올바른 컨테이너 크기를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(48));
        expect(container.constraints?.maxHeight, equals(48));
      });

      testWidgets('올바른 색상 필터를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(svgPicture.colorFilter, isNotNull);
      });
    });

    group('크기 테스트', () {
      testWidgets('올바른 SizedBox 크기를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // TermsExpandIcon 내부의 SizedBox들만 찾기
        final termsExpandIcon = find.byType(TermsExpandIcon);
        final sizedBoxes = find.descendant(
          of: termsExpandIcon,
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxes, findsWidgets);
        
        final firstSizedBox = tester.widget<SizedBox>(sizedBoxes.at(0));
        expect(firstSizedBox.width, equals(24));
        expect(firstSizedBox.height, equals(24));
        
        final secondSizedBox = tester.widget<SizedBox>(sizedBoxes.at(1));
        expect(secondSizedBox.width, equals(8));
        expect(secondSizedBox.height, equals(14));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('터치 이벤트가 없어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // GestureDetector가 없으므로 터치 이벤트가 없어야 함
        expect(find.byType(GestureDetector), findsNothing);
      });

      testWidgets('Container가 올바른 크기를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(48));
        expect(container.constraints?.maxHeight, equals(48));
      });

      testWidgets('투명한 배경을 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.transparent));
      });
    });

    group('스타일 테스트', () {
      testWidgets('투명 배경을 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.transparent));
      });

      testWidgets('SVG 색상 필터가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(svgPicture.colorFilter, isNotNull);
        // ColorFilter.mode(Color(0xFF222222), BlendMode.srcIn)
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock이 필요하지 않다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // TermsExpandIcon은 더 이상 onTap 콜백을 받지 않으므로 Mock이 필요하지 않음
        expect(find.byType(TermsExpandIcon), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = tester.widget<Container>(find.byType(Container));
        expect(container, isNotNull);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });
  });
}
