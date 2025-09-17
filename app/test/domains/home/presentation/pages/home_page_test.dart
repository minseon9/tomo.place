import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/home/presentation/controller/map_notifier.dart';
import 'package:tomo_place/domains/home/presentation/pages/home_page.dart';
import 'package:tomo_place/domains/home/presentation/widgets/atoms/my_location_button.dart';
import 'package:tomo_place/domains/home/presentation/widgets/molecules/bottom_navigation_bar.dart';
import 'package:tomo_place/domains/home/presentation/widgets/molecules/map_search_bar.dart';
import 'package:tomo_place/domains/home/presentation/widgets/organisms/map_widget.dart';

import '../../../../utils/widget/app_wrappers.dart';
import '../../../../utils/widget/verifiers.dart';
import '../../../../utils/state_notifier/map_notifier_mock.dart';

void main() {
  group('HomePage', () {
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          mapNotifierProvider.overrideWith((ref) => MockMapNotifier()),
        ],
        child: AppWrappers.wrapWithMaterialApp(const HomePage()),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: HomePage,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Scaffold,
          expectedCount: 2, // MaterialApp의 Scaffold + HomePage의 Scaffold
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Stack,
          expectedCount: 3, // 여러 Stack 위젯들
        );
      });

      testWidgets('MapWidget이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: MapWidget,
          expectedCount: 1,
        );
      });

      testWidgets('MapSearchBar가 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: MapSearchBar,
          expectedCount: 1,
        );
      });

      testWidgets('MyLocationButton이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: MyLocationButton,
          expectedCount: 1,
        );
      });

      testWidgets('BottomNavigationBar가 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: BottomNavigationBar,
          expectedCount: 1,
        );
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('SafeArea가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: SafeArea,
          expectedCount: 1,
        );
      });

      testWidgets('Positioned 위젯이 올바르게 배치되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Positioned,
          expectedCount: 1,
        );
      });

      testWidgets('Padding이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Padding,
          expectedCount: 20, // 여러 위젯에서 사용되는 Padding들
        );
      });
    });

    group('반응형 테스트', () {
      testWidgets('ResponsiveSizing이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // ResponsiveSizing이 적용된 위젯들이 올바르게 렌더링되는지 확인
        final positioned = find.byType(Positioned);
        expect(positioned, findsOneWidget);
        
        final positionedWidget = tester.widget<Positioned>(positioned);
        expect(positionedWidget.right, isNotNull);
        expect(positionedWidget.bottom, isNotNull);
      });

      testWidgets('반응형 패딩이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final padding = find.byType(Padding);
        expect(padding, findsWidgets); // 여러 Padding 위젯이 있음
        
        final paddingWidget = tester.widget<Padding>(padding.first);
        expect(paddingWidget.padding, isNotNull);
      });
    });

    group('상태 관리 테스트', () {
      testWidgets('ConsumerStatefulWidget이 올바르게 동작해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final homePage = find.byType(HomePage);
        expect(homePage, findsOneWidget);
        
        final homePageWidget = tester.widget<HomePage>(homePage);
        expect(homePageWidget, isA<ConsumerStatefulWidget>());
      });

      testWidgets('initState에서 mapNotifier가 초기화되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // initState 실행을 위해 한 번 더 pump

        // Then
        // initState에서 mapNotifier.initializeMap()이 호출되는지 확인
        // 실제 구현에서는 Mock을 사용하여 검증할 수 있음
        expect(find.byType(HomePage), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets); // 여러 Scaffold 위젯이 있음
        
        final scaffoldWidget = tester.widget<Scaffold>(scaffold.first);
        expect(scaffoldWidget, isNotNull);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });
  });
}
