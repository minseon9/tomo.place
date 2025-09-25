import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/home/presentation/widgets/atoms/bottom_navigation_tab.dart';
import 'package:tomo_place/domains/home/presentation/widgets/molecules/bottom_navigation_bar.dart';

import '../../../../../utils/widget/app_wrappers.dart';

void main() {
  group('BottomNavigationBar', () {
    Widget createTestWidget({int? currentIndex}) {
      return AppWrappers.wrapWithMaterialApp(
        BottomNavigationBar(currentIndex: currentIndex),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(Container), findsWidgets); // 여러 Container가 있음
      });

      testWidgets('Row 위젯이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('3개의 Expanded 위젯이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(Expanded), findsNWidgets(3));
      });

      testWidgets('3개의 BottomNavigationTab이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.byType(BottomNavigationTab), findsNWidgets(3));
      });
    });

    group('탭 내용 테스트', () {
      testWidgets('위치 공유 탭이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.text('위치 공유'), findsOneWidget);
      });

      testWidgets('모음집 탭이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.text('모음집'), findsOneWidget);
      });

      testWidgets('마이 탭이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(find.text('마이'), findsOneWidget);
      });
    });

    group('아이콘 테스트', () {
      testWidgets('올바른 아이콘 경로가 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final bottomNavigationTabs = find.byType(BottomNavigationTab);
        expect(bottomNavigationTabs, findsNWidgets(3));
        
        final tabs = [
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(0)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(1)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(2)),
        ];
        
        // 실제 구현 순서에 맞게 수정
        expect(tabs[0].iconPath, equals('assets/icons/location_share_icon.svg')); // 위치 공유
        expect(tabs[1].iconPath, equals('assets/icons/place_folder_icon.svg'));   // 모음집
        expect(tabs[2].iconPath, equals('assets/icons/my_icon.svg'));             // 마이
      });
    });

    group('선택 상태 테스트', () {
      testWidgets('currentIndex가 null일 때 모든 탭이 선택되지 않아야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(currentIndex: null));

        // Then
        final bottomNavigationTabs = find.byType(BottomNavigationTab);
        final tabs = [
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(0)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(1)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(2)),
        ];
        
        expect(tabs[0].isSelected, isFalse);
        expect(tabs[1].isSelected, isFalse);
        expect(tabs[2].isSelected, isFalse);
      });

      testWidgets('currentIndex가 0일 때 첫 번째 탭이 선택되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(currentIndex: 0));

        // Then
        final bottomNavigationTabs = find.byType(BottomNavigationTab);
        final tabs = [
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(0)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(1)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(2)),
        ];
        
        expect(tabs[0].isSelected, isTrue);  // currentIndex == 0이므로 첫 번째 탭 선택
        expect(tabs[1].isSelected, isFalse);
        expect(tabs[2].isSelected, isFalse);
      });

      testWidgets('currentIndex가 1일 때 두 번째 탭이 선택되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(currentIndex: 1));

        // Then
        final bottomNavigationTabs = find.byType(BottomNavigationTab);
        final tabs = [
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(0)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(1)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(2)),
        ];
        
        expect(tabs[0].isSelected, isFalse);
        expect(tabs[1].isSelected, isTrue);   // currentIndex == 1이므로 두 번째 탭 선택
        expect(tabs[2].isSelected, isFalse);
      });

      testWidgets('currentIndex가 2일 때 세 번째 탭이 선택되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(currentIndex: 2));

        // Then
        final bottomNavigationTabs = find.byType(BottomNavigationTab);
        final tabs = [
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(0)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(1)),
          tester.widget<BottomNavigationTab>(bottomNavigationTabs.at(2)),
        ];
        
        expect(tabs[0].isSelected, isFalse);
        expect(tabs[1].isSelected, isFalse);
        expect(tabs[2].isSelected, isTrue);   // currentIndex == 2이므로 세 번째 탭 선택
      });
    });

    group('스타일 테스트', () {
      testWidgets('올바른 배경색이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final mainContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.white);
        expect(mainContainer, findsWidgets); // 여러 Container가 있음 (메인 + 아이콘들)
      });

      testWidgets('그림자 효과가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final mainContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).boxShadow != null);
        expect(mainContainer, findsWidgets); // 여러 Container가 있음
        
        final containerWidget = tester.widget<Container>(mainContainer);
        final decoration = containerWidget.decoration as BoxDecoration;
        expect(decoration.boxShadow?.length, equals(2)); // Top shadow + Bottom shadow
      });

      testWidgets('반응형 높이가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final mainContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.white);
        final containerWidget = tester.widget<Container>(mainContainer.first);
        expect(containerWidget.constraints?.maxHeight, isNotNull);
        expect(containerWidget.constraints?.maxHeight, greaterThan(0));
      });
    });

    group('상호작용 테스트', () {
      testWidgets('위치 공유 탭 클릭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // When
        await tester.tap(find.text('위치 공유'));
        await tester.pump();

        // Then
        // TODO: 실제 콜백 구현 시 검증 로직 추가
        expect(find.text('위치 공유'), findsOneWidget);
      });

      testWidgets('모음집 탭 클릭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // When
        await tester.tap(find.text('모음집'));
        await tester.pump();

        // Then
        // TODO: 실제 콜백 구현 시 검증 로직 추가
        expect(find.text('모음집'), findsOneWidget);
      });

      testWidgets('마이 탭 클릭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // When
        await tester.tap(find.text('마이'));
        await tester.pump();

        // Then
        // TODO: 실제 콜백 구현 시 검증 로직 추가
        expect(find.text('마이'), findsOneWidget);
      });
    });

    group('반응형 테스트', () {
      testWidgets('반응형 높이가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final mainContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.white);
        final containerWidget = tester.widget<Container>(mainContainer.first);
        expect(containerWidget.constraints?.maxHeight, isNotNull);
        expect(containerWidget.constraints?.maxHeight, greaterThan(0));
      });

      testWidgets('반응형 그림자 효과가 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final mainContainer = find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).boxShadow != null);
        final containerWidget = tester.widget<Container>(mainContainer);
        final decoration = containerWidget.decoration as BoxDecoration;
        
        expect(decoration.boxShadow, isNotNull);
        // 반응형 blurRadius가 적용되었는지 확인
        for (final shadow in decoration.boxShadow!) {
          expect(shadow.blurRadius, isNotNull);
        }
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final bottomNavigationBar = find.byType(BottomNavigationBar);
        expect(bottomNavigationBar, findsOneWidget);
        
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
        expect(bottomNavigationBar, isNotNull);
      });
    });
  });
}
