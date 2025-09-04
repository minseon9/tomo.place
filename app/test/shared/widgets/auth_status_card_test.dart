import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:app/shared/ui/components/auth_status_card.dart';
import '../../utils/fake_data_generator.dart';
import '../../utils/widget_test_utils.dart';

void main() {
  group('AuthStatusCard', () {
    late AuthenticationResult authenticatedResult;
    late AuthenticationResult unauthenticatedResult;
    late AuthenticationResult expiredResult;

    setUp(() {
      authenticatedResult = FakeDataGenerator.createAuthenticatedResult();
      unauthenticatedResult = FakeDataGenerator.createUnauthenticatedResult();
      expiredResult = FakeDataGenerator.createExpiredResult();
    });

    group('렌더링 테스트', () {
      testWidgets('인증된 상태로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: authenticatedResult),
          ),
        );

        // 헤더 확인
        expect(find.text('Authentication Status'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // 상태 정보 확인
        expect(find.text('Status: Authenticated'), findsOneWidget);
        expect(find.textContaining('Access Token:'), findsOneWidget);
        expect(find.textContaining('Expires:'), findsOneWidget);

        // 액션 버튼이 없는지 확인 (콜백이 제공되지 않음)
        expect(find.text('Refresh'), findsNothing);
        expect(find.text('Logout'), findsNothing);
      });

      testWidgets('미인증 상태로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: unauthenticatedResult),
          ),
        );

        // 헤더 확인
        expect(find.text('Authentication Status'), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);

        // 상태 정보 확인
        expect(find.text('Status: Unauthenticated'), findsOneWidget);
        // unauthenticated result는 기본 메시지를 제공함
        expect(find.text('Message: Authentication required'), findsOneWidget);

        // 토큰 정보가 없는지 확인
        expect(find.textContaining('Access Token:'), findsNothing);
        expect(find.textContaining('Expires:'), findsNothing);
      });

      testWidgets('만료된 상태로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: expiredResult),
          ),
        );

        // 헤더 확인
        expect(find.text('Authentication Status'), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);

        // 상태 정보 확인
        expect(find.text('Status: Expired'), findsOneWidget);
        // expired result는 기본 메시지를 제공함
        expect(find.text('Message: Token expired'), findsOneWidget);
        
        // expired status는 토큰 정보가 없어야 함
        expect(find.textContaining('Access Token:'), findsNothing);
        expect(find.textContaining('Expires:'), findsNothing);
      });
    });

    group('액션 버튼 테스트', () {
      testWidgets('Refresh 콜백이 제공되면 Refresh 버튼이 표시되어야 한다', (WidgetTester tester) async {
        bool refreshCalled = false;
        
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(
              authResult: authenticatedResult,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        );

        expect(find.text('Refresh'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // 버튼 탭 테스트
        await WidgetTestActions.tapButton(tester, 'Refresh');
        expect(refreshCalled, isTrue);
      });

      testWidgets('Logout 콜백이 제공되면 Logout 버튼이 표시되어야 한다', (WidgetTester tester) async {
        bool logoutCalled = false;
        
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(
              authResult: authenticatedResult,
              onLogout: () => logoutCalled = true,
            ),
          ),
        );

        expect(find.text('Logout'), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);

        // 버튼 탭 테스트
        await WidgetTestActions.tapButton(tester, 'Logout');
        expect(logoutCalled, isTrue);
      });

      testWidgets('두 콜백이 모두 제공되면 두 버튼이 모두 표시되어야 한다', (WidgetTester tester) async {
        bool refreshCalled = false;
        bool logoutCalled = false;
        
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(
              authResult: authenticatedResult,
              onRefresh: () => refreshCalled = true,
              onLogout: () => logoutCalled = true,
            ),
          ),
        );

        expect(find.text('Refresh'), findsOneWidget);
        expect(find.text('Logout'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);

        // Refresh 버튼 탭
        await WidgetTestActions.tapButton(tester, 'Refresh');
        expect(refreshCalled, isTrue);
        expect(logoutCalled, isFalse);

        // Logout 버튼 탭
        await WidgetTestActions.tapButton(tester, 'Logout');
        expect(logoutCalled, isTrue);
      });
    });

    group('스타일 테스트', () {
      testWidgets('인증된 상태의 색상이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: authenticatedResult),
          ),
        );

        final headerText = tester.widget<Text>(
          find.text('Authentication Status'),
        );
        expect(headerText.style?.color, equals(Colors.green));

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.check_circle),
        );
        expect(icon.color, equals(Colors.green));
      });

      testWidgets('미인증 상태의 색상이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: unauthenticatedResult),
          ),
        );

        final headerText = tester.widget<Text>(
          find.text('Authentication Status'),
        );
        expect(headerText.style?.color, equals(Colors.red));

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.cancel),
        );
        expect(icon.color, equals(Colors.red));
      });

      testWidgets('만료된 상태의 색상이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: expiredResult),
          ),
        );

        final headerText = tester.widget<Text>(
          find.text('Authentication Status'),
        );
        expect(headerText.style?.color, equals(Colors.orange));

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.warning),
        );
        expect(icon.color, equals(Colors.orange));
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('카드가 올바른 마진과 패딩을 가져야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: authenticatedResult),
          ),
        );

        final card = tester.widget<Card>(find.byType(Card).first);
        expect(card.margin, equals(const EdgeInsets.all(16.0)));

        final padding = tester.widget<Padding>(find.byType(Padding).first);
        expect(padding.padding, equals(const EdgeInsets.all(16.0)));
      });

      testWidgets('요소들 사이에 적절한 간격이 있어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: authenticatedResult),
          ),
        );

        // SizedBox들이 올바른 높이를 가져야 함
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes.evaluate().length, greaterThanOrEqualTo(2));

        // 16.0 높이의 SizedBox들이 있는지 확인 (헤더와 상태 정보 사이, 상태 정보와 액션 사이)
        final height16Boxes = sizedBoxes.evaluate()
            .where((element) => (element.widget as SizedBox).height == 16.0)
            .toList();
        expect(height16Boxes.length, greaterThanOrEqualTo(2));
      });
    });

    group('접근성 테스트', () {
      testWidgets('모든 텍스트가 읽기 가능해야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: authenticatedResult),
          ),
        );

        // 주요 텍스트들이 모두 표시되어야 함
        expect(find.text('Authentication Status'), findsOneWidget);
        expect(find.text('Status: Authenticated'), findsOneWidget);
        expect(find.textContaining('Access Token:'), findsOneWidget);
        expect(find.textContaining('Expires:'), findsOneWidget);
      });

      testWidgets('아이콘이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(authResult: authenticatedResult),
          ),
        );

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsNothing); // 콜백이 제공되지 않음
        expect(find.byIcon(Icons.logout), findsNothing); // 콜백이 제공되지 않음
      });
    });

    group('상호작용 테스트', () {
      testWidgets('Refresh 버튼 탭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        bool refreshCalled = false;
        
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(
              authResult: authenticatedResult,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        );

        await WidgetTestActions.tapButton(tester, 'Refresh');
        expect(refreshCalled, isTrue);
      });

      testWidgets('Logout 버튼 탭 시 콜백이 호출되어야 한다', (WidgetTester tester) async {
        bool logoutCalled = false;
        
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(
              authResult: authenticatedResult,
              onLogout: () => logoutCalled = true,
            ),
          ),
        );

        await WidgetTestActions.tapButton(tester, 'Logout');
        expect(logoutCalled, isTrue);
      });

      testWidgets('버튼이 비활성화되지 않아야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(
          WidgetTestUtils.createTestApp(
            child: AuthStatusCard(
              authResult: authenticatedResult,
              onRefresh: () {},
              onLogout: () {},
            ),
          ),
        );

        // 먼저 버튼 텍스트가 있는지 확인
        expect(find.text('Refresh'), findsOneWidget);
        expect(find.text('Logout'), findsOneWidget);

        // ElevatedButton들을 찾아서 onPressed가 null이 아닌지 확인
        final elevatedButtons = find.byType(ElevatedButton);
        expect(elevatedButtons, findsNWidgets(2));

        final refreshButton = tester.widget<ElevatedButton>(elevatedButtons.first);
        expect(refreshButton.onPressed, isNotNull);

        final logoutButton = tester.widget<ElevatedButton>(elevatedButtons.at(1));
        expect(logoutButton.onPressed, isNotNull);
      });
    });
  });
}
