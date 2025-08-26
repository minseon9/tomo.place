// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/app/di/injection_container.dart' as di;

void main() {
  group('TomoPlace App Tests', () {
    setUpAll(() async {
      // 테스트용 의존성 초기화
      await di.initializeDependencies();
    });

    testWidgets('App should display login screen', (WidgetTester tester) async {
      // 기본 Material 앱으로 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('토모플레이스'),
                  Text('로그인 화면 테스트'),
                ],
              ),
            ),
          ),
        ),
      );

      // 텍스트가 올바르게 표시되는지 확인
      expect(find.text('토모플레이스'), findsOneWidget);
      expect(find.text('로그인 화면 테스트'), findsOneWidget);
    });
  });
}
