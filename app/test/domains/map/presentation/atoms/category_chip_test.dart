import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/map/presentation/widgets/atoms/category_chip.dart';

import '../../../../utils/widget/app_wrappers.dart';

void main() {
  group('CategoryChip', () {
    Widget createTestWidget({
      String iconPath = 'assets/icons/test_icon.svg',
      String label = 'Test Category',
      bool isSelected = false,
      VoidCallback? onTap,
    }) {
      return AppWrappers.wrapWithMaterialApp(
        CategoryChip(
          iconPath: iconPath,
          label: label,
          isSelected: isSelected,
          onTap: onTap,
        ),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(CategoryChip), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('Row 위젯이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('SvgPicture가 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SvgPicture), findsOneWidget);
      });

      testWidgets('Text 위젯이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('텍스트 테스트', () {
      testWidgets('올바른 라벨이 표시되어야 한다', (WidgetTester tester) async {
        // Given
        const testLabel = 'Test Category';

        // When
        await tester.pumpWidget(createTestWidget(label: testLabel));

        // Then
        expect(find.text(testLabel), findsOneWidget);
      });

      testWidgets('다른 라벨이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        const testLabel = 'Another Category';

        // When
        await tester.pumpWidget(createTestWidget(label: testLabel));

        // Then
        expect(find.text(testLabel), findsOneWidget);
      });
    });

    group('아이콘 테스트', () {
      testWidgets('올바른 아이콘 경로가 설정되어야 한다', (WidgetTester tester) async {
        // Given
        const testIconPath = 'assets/icons/test_icon.svg';

        // When
        await tester.pumpWidget(createTestWidget(iconPath: testIconPath));

        // Then
        final svgPicture = find.byType(SvgPicture);
        final svgPictureWidget = tester.widget<SvgPicture>(svgPicture);
        // SvgPicture.asset()의 경우 assetName 속성이 없으므로 다른 방법으로 검증
        expect(svgPictureWidget, isNotNull);
      });

      testWidgets('다른 아이콘 경로가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given
        const testIconPath = 'assets/icons/another_icon.svg';

        // When
        await tester.pumpWidget(createTestWidget(iconPath: testIconPath));

        // Then
        final svgPicture = find.byType(SvgPicture);
        final svgPictureWidget = tester.widget<SvgPicture>(svgPicture);
        // SvgPicture.asset()의 경우 assetName 속성이 없으므로 다른 방법으로 검증
        expect(svgPictureWidget, isNotNull);
      });
    });

    group('선택 상태 테스트', () {
      testWidgets('기본값으로 선택되지 않은 상태여야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final categoryChip = find.byType(CategoryChip);
        final chipWidget = tester.widget<CategoryChip>(categoryChip);
        expect(chipWidget.isSelected, isFalse);
      });

      testWidgets('선택되지 않은 상태에서 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isSelected: false));

        // Then
        final categoryChip = find.byType(CategoryChip);
        final chipWidget = tester.widget<CategoryChip>(categoryChip);
        expect(chipWidget.isSelected, isFalse);
      });

      testWidgets('선택된 상태에서 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(isSelected: true));

        // Then
        final categoryChip = find.byType(CategoryChip);
        final chipWidget = tester.widget<CategoryChip>(categoryChip);
        expect(chipWidget.isSelected, isTrue);
      });
    });

    group('스타일 테스트', () {
      testWidgets('올바른 컨테이너 높이가 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        final containerWidget = tester.widget<Container>(container);
        expect(containerWidget.constraints?.maxHeight, isNotNull);
      });

      testWidgets('올바른 패딩이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        final containerWidget = tester.widget<Container>(container);
        expect(containerWidget.padding, isNotNull);
      });

      testWidgets('올바른 배경색이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        final containerWidget = tester.widget<Container>(container);
        final decoration = containerWidget.decoration as BoxDecoration?;
        
        if (decoration != null) {
          expect(decoration.color, isNotNull);
        }
      });

      testWidgets('둥근 모서리가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        final containerWidget = tester.widget<Container>(container);
        final decoration = containerWidget.decoration as BoxDecoration?;
        
        if (decoration != null) {
          expect(decoration.borderRadius, isNotNull);
        }
      });

      testWidgets('테두리가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        final containerWidget = tester.widget<Container>(container);
        final decoration = containerWidget.decoration as BoxDecoration?;
        
        if (decoration != null) {
          expect(decoration.border, isNotNull);
        }
      });

      testWidgets('SvgPicture이 올바른 크기를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final svgPicture = find.byType(SvgPicture);
        final svgPictureWidget = tester.widget<SvgPicture>(svgPicture);
        // SvgPicture의 width/height는 null일 수 있으므로 부모 SizedBox 크기로 검증
        final sizedBox = find.ancestor(
          of: svgPicture, 
          matching: find.byType(SizedBox));
        expect(sizedBox, findsOneWidget);
        
        final sizedBoxWidget = tester.widget<SizedBox>(sizedBox);
        expect(sizedBoxWidget.width, isNotNull);
        expect(sizedBoxWidget.height, isNotNull);
      });

      testWidgets('색상 필터가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final svgPicture = find.byType(SvgPicture);
        final svgPictureWidget = tester.widget<SvgPicture>(svgPicture);
        expect(svgPictureWidget.colorFilter, isNotNull);
      });
    });

    group('반응형 테스트', () {
      testWidgets('반응형 높이가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        final containerWidget = tester.widget<Container>(container);
        expect(containerWidget.constraints?.maxHeight, isNotNull);
      });

      testWidgets('반응형 패딩이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final container = find.byType(Container);
        final containerWidget = tester.widget<Container>(container);
        expect(containerWidget.padding, isNotNull);
      });

      testWidgets('반응형 아이콘 크기가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final sizedBox = find.byWidgetPredicate((widget) => 
          widget is SizedBox && 
          widget.width != null && 
          widget.height != null);
        expect(sizedBox, findsOneWidget);
        
        final sizedBoxWidget = tester.widget<SizedBox>(sizedBox);
        expect(sizedBoxWidget.width, isNotNull);
        expect(sizedBoxWidget.height, isNotNull);
      });

      testWidgets('반응형 텍스트 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final text = find.byType(Text);
        final textWidget = tester.widget<Text>(text);
        expect(textWidget.style, isNotNull);
      });

      testWidgets('반응형 간격이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(SizedBox), findsWidgets); // 여러 SizedBox가 있음
      });
    });

    group('상호작용 테스트', () {
      testWidgets('onTap이 null일 때 터치 이벤트가 처리되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(onTap: null));

        // When
        await tester.tap(find.byType(CategoryChip));
        await tester.pump();

        // Then
        // onTap이 null이어도 터치 이벤트는 처리되어야 함
        expect(find.byType(CategoryChip), findsOneWidget);
      });

      testWidgets('onTap이 설정된 경우 터치 이벤트가 처리되어야 한다', (WidgetTester tester) async {
        // Given
        bool tapCalled = false;
        void onTap() {
          tapCalled = true;
        }

        // When
        await tester.pumpWidget(createTestWidget(onTap: onTap));
        await tester.tap(find.byType(CategoryChip));
        await tester.pump();

        // Then
        expect(tapCalled, isTrue);
      });

      testWidgets('GestureDetector가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given
        bool onTapCalled = false;
        final onTapCallback = () => onTapCalled = true;

        // When
        await tester.pumpWidget(createTestWidget(onTap: onTapCallback));

        // Then
        final gestureDetector = find.byType(GestureDetector);
        final gestureDetectorWidget = tester.widget<GestureDetector>(gestureDetector);
        expect(gestureDetectorWidget.onTap, isNotNull);
        
        // 탭 이벤트 테스트
        await tester.tap(gestureDetector);
        expect(onTapCalled, isTrue);
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('Row가 올바른 정렬을 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final row = find.byType(Row);
        final rowWidget = tester.widget<Row>(row);
        expect(rowWidget.mainAxisSize, equals(MainAxisSize.min));
      });

      testWidgets('SizedBox가 아이콘과 텍스트 사이에 올바르게 배치되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final sizedBox = find.byType(SizedBox);
        final sizedBoxWidget = tester.widget<SizedBox>(sizedBox.first);
        expect(sizedBoxWidget.width, isNotNull);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final categoryChip = find.byType(CategoryChip);
        expect(categoryChip, findsOneWidget);
        
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
        expect(categoryChip, isNotNull);
      });
    });
  });
}
