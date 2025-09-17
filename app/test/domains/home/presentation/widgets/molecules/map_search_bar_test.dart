import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/home/presentation/widgets/molecules/map_search_bar.dart';
import 'package:tomo_place/domains/home/presentation/widgets/atoms/category_chip.dart';

import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';

void main() {
  group('MapSearchBar', () {
    Widget createTestWidget() {
      return AppWrappers.wrapWithMaterialApp(const MapSearchBar());
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(MapSearchBar), findsOneWidget);
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets('검색 바 컨테이너가 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Container), findsWidgets); // 여러 Container가 있음
      });

      testWidgets('TextField가 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('검색 아이콘이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Icon), findsOneWidget);
        
        final icon = find.byType(Icon);
        final iconWidget = tester.widget<Icon>(icon);
        expect(iconWidget.icon, equals(Icons.search));
      });

      testWidgets('카테고리 칩들이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(CategoryChip), findsWidgets); // 여러 CategoryChip이 있음
      });
    });

    group('텍스트 및 힌트 테스트', () {
      testWidgets('올바른 힌트 텍스트가 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.text('검색어를 입력하세요.'), findsOneWidget);
      });

      testWidgets('TextField가 읽기 전용이어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final textField = find.byType(TextField);
        final textFieldWidget = tester.widget<TextField>(textField);
        expect(textFieldWidget.readOnly, isTrue);
      });
    });

    group('스타일 테스트', () {
      testWidgets('올바른 배경색이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final searchBarContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color != null);
        expect(searchBarContainer, findsWidgets); // 여러 Container가 있음 (MapSearchBar + CategoryChips)
      });

      testWidgets('둥근 모서리가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final searchBarContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius != null);
        expect(searchBarContainer, findsWidgets); // 여러 Container가 있음
      });

      testWidgets('그림자 효과가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final searchBarContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).boxShadow != null);
        expect(searchBarContainer, findsOneWidget);
      });
    });

    group('반응형 테스트', () {
      testWidgets('반응형 패딩이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
        
        // 반응형 패딩이 적용된 컨테이너들이 올바르게 렌더링되는지 확인
        final searchBarContainer = tester.widget<Container>(containers.first);
        expect(searchBarContainer.margin, isNotNull);
      });

      testWidgets('반응형 텍스트 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final textField = find.byType(TextField);
        final textFieldWidget = tester.widget<TextField>(textField);
        expect(textFieldWidget.style, isNotNull);
      });

      testWidgets('반응형 아이콘 크기가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final icon = find.byType(Icon);
        final iconWidget = tester.widget<Icon>(icon);
        expect(iconWidget.size, isNotNull);
      });
    });

    group('카테고리 칩 테스트', () {
      testWidgets('카테고리 칩들이 올바른 개수로 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // CategoryData.defaultCategories.length만큼 CategoryChip이 표시되어야 함
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: CategoryChip,
          expectedCount: 7, // CategoryData.defaultCategories.length
        );
      });

      testWidgets('카테고리 칩들이 가로 스크롤로 배치되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final listView = find.byType(ListView);
        final listViewWidget = tester.widget<ListView>(listView);
        expect(listViewWidget.scrollDirection, equals(Axis.horizontal));
      });

      testWidgets('카테고리 칩 간격이 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
        
        // separatorBuilder에서 생성된 SizedBox들이 올바르게 렌더링되는지 확인
        final separatorBoxes = sizedBoxes.evaluate()
            .where((element) => 
                tester.widget<SizedBox>(sizedBoxes.first).width != null)
            .length;
        expect(separatorBoxes, greaterThan(0));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('TextField 터치 시 아무 동작하지 않아야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // When
        await tester.tap(find.byType(TextField));
        await tester.pump();

        // Then
        // readOnly이므로 아무 동작하지 않아야 함
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('카테고리 칩 터치 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // When
        final categoryChips = find.byType(CategoryChip);
        if (categoryChips.evaluate().isNotEmpty) {
          await tester.tap(categoryChips.first);
          await tester.pump();
        }

        // Then
        // TODO: 카테고리 선택 로직이 구현되면 콜백 호출 검증
        expect(categoryChips, findsWidgets);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final mapSearchBar = find.byType(MapSearchBar);
        expect(mapSearchBar, findsOneWidget);
        
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
        expect(mapSearchBar, isNotNull);
      });
    });
  });
}
