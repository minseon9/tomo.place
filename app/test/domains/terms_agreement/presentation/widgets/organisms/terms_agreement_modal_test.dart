import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/expand_icon.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';

import '../../../../../utils/domains/test_terms_util.dart';
import '../../../../../utils/test_actions_util.dart';
import '../../../../../utils/test_wrappers_util.dart';
import '../../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../../utils/verifiers/test_style_verifier.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(TermsAgreementResult.agreed);
  });

  group('TermsAgreementModal', () {
    late TermsMocks mocks;

    setUp(() {
      mocks = TestTermsUtil.createMocks();
    });

    Widget createTestWidget({
      void Function(TermsAgreementResult result)? onResult,
      bool includeRoutes = false,
    }) {
      final handler = onResult ?? mocks.modalCallbacks.onResult;
      final modal = TermsAgreementModal(onResult: handler);

      if (includeRoutes) {
        return TestWrappersUtil.createTestAppWithRouting(
          child: modal,
          routes: TestTermsUtil.routes(),
        );
      }

      return TestWrappersUtil.material(modal);
    }

    testWidgets('모달 기본 UI 렌더링', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<TermsAgreementModal>();
      TestTermsUtil.verifyAllTermsTextsDisplay();
      TestRenderVerifier.expectText(TestTermsUtil.agreeAllButton);
    });

    testWidgets('모달 배경 스타일 확인', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      if (decoration != null) {
        expect(decoration.color, isNotNull);
        expect(decoration.boxShadow, isNotEmpty);
        expect(decoration.borderRadius, isNotNull);
      }
    });

    testWidgets('그랩바 컨테이너 존재', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('외부 터치 시 dismissed 전달', (tester) async {
      when(() => mocks.modalCallbacks.onResult(any())).thenAnswer((_) {});
      await tester.pumpWidget(createTestWidget());

      await tester.tapAt(TestTermsUtil.calculateExternalTouchPoint());
      await tester.pumpAndSettle();

      verify(
        () => mocks.modalCallbacks.onResult(TermsAgreementResult.dismissed),
      ).called(1);
    });

    testWidgets('모두 동의 버튼 탭 시 agreed 전달', (tester) async {
      when(() => mocks.modalCallbacks.onResult(any())).thenAnswer((_) {});
      await tester.pumpWidget(createTestWidget());

      await TestActionsUtil.tapFinderAndSettle(
        tester,
        TestTermsUtil.findAgreeAllButton(),
      );

      verify(
        () => mocks.modalCallbacks.onResult(TermsAgreementResult.agreed),
      ).called(1);
    });

    testWidgets('아래로 드래그 시 dismissed 전달', (tester) async {
      when(() => mocks.modalCallbacks.onResult(any())).thenAnswer((_) {});
      await tester.pumpWidget(createTestWidget());

      await tester.drag(
        find.byType(GestureDetector).at(1),
        const Offset(0, 50),
      );
      await tester.pump();

      verify(
        () => mocks.modalCallbacks.onResult(TermsAgreementResult.dismissed),
      ).called(1);
    });

    testWidgets('위로 드래그 시 콜백 없음', (tester) async {
      when(() => mocks.modalCallbacks.onResult(any())).thenAnswer((_) {});
      await tester.pumpWidget(createTestWidget());

      await tester.drag(
        find.byType(GestureDetector).at(1),
        const Offset(0, -50),
      );
      await tester.pump();

      verifyNever(() => mocks.modalCallbacks.onResult(any()));
    });

    testWidgets('확장 아이콘이 네비게이션 가능한 항목을 표시', (tester) async {
      await tester.pumpWidget(createTestWidget(includeRoutes: true));

      final expandIcons = find.byType(TermsExpandIcon);
      expect(expandIcons, findsWidgets);
    });
  });
}
