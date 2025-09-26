import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_sizing.dart';

import '../../../utils/test_responsive_util.dart';
import '../../../utils/test_wrappers_util.dart';

void main() {
  group('ResponsiveSizing', () {
    group('getResponsiveEdge', () {
      testWidgets('모바일에서 1.0x 패딩 스케일링 적용', (tester) async {
        const padding = EdgeInsets.fromLTRB(16, 8, 16, 8);
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          reader: (context) => ResponsiveSizing.getResponsiveEdge(
            context,
            left: padding.left,
            top: padding.top,
            right: padding.right,
            bottom: padding.bottom,
          ),
        );

        expect(result, padding);
      });

      testWidgets('태블릿에서 1.2x 패딩 스케일링 적용', (tester) async {
        const padding = EdgeInsets.fromLTRB(16, 8, 16, 8);
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          reader: (context) => ResponsiveSizing.getResponsiveEdge(
            context,
            left: padding.left,
            top: padding.top,
            right: padding.right,
            bottom: padding.bottom,
          ),
        );

        expect(result, const EdgeInsets.fromLTRB(19.2, 9.6, 19.2, 9.6));
      });

      testWidgets('기본값 0으로 패딩 생성', (tester) async {
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          reader: (context) => ResponsiveSizing.getResponsiveEdge(context),
        );
        expect(result, EdgeInsets.zero);
      });

      testWidgets('음수 패딩 값 처리', (tester) async {
        const padding = EdgeInsets.fromLTRB(-10, -5, -10, -5);
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          reader: (context) => ResponsiveSizing.getResponsiveEdge(
            context,
            left: padding.left,
            top: padding.top,
            right: padding.right,
            bottom: padding.bottom,
          ),
        );

        expect(result, const EdgeInsets.fromLTRB(-12, -6, -12, -6));
      });
    });

    group('getResponsiveSymmetricEdge', () {
      testWidgets('모바일에서 1.0x 패딩 스케일링 적용', (tester) async {
        const padding = EdgeInsets.symmetric(vertical: 16, horizontal: 8);
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          reader: (context) => ResponsiveSizing.getResponsiveSymmetricEdge(
            context,
            vertical: padding.vertical,
            horizontal: padding.horizontal,
          ),
        );

        expect(result, padding);
      });

      testWidgets('태블릿에서 1.2x 패딩 스케일링 적용', (tester) async {
        const padding = EdgeInsets.symmetric(vertical: 16, horizontal: 8);
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          reader: (context) => ResponsiveSizing.getResponsiveSymmetricEdge(
            context,
            vertical: padding.vertical,
            horizontal: padding.horizontal,
          ),
        );

        expect(result, const EdgeInsets.symmetric(vertical: 19.2, horizontal: 9.6));
      });

      testWidgets('기본값 0으로 패딩 생성', (tester) async {
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          reader: (context) => ResponsiveSizing.getResponsiveSymmetricEdge(context),
        );

        expect(result, EdgeInsets.zero);
      });

      testWidgets('음수 패딩 값 처리', (tester) async {
        const padding = EdgeInsets.fromLTRB(-10, -5, -10, -5);
        final result = await _readPaddingValue<EdgeInsets>(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          reader: (context) => ResponsiveSizing.getResponsiveSymmetricEdge(
            context,
            vertical: padding.vertical,
            horizontal: padding.horizontal,
          ),
        );

        expect(result, const EdgeInsets.symmetric(vertical: -12, horizontal: -6));
      });
    });

    group('getResponsiveHeight', () {
      testWidgets('화면 높이의 50% 반환', (tester) async {
        const heightPercent = 0.5;
        final result = await _readPaddingValue<double>(
          tester,
          screenSize: const Size(400, 800),
          reader: (context) => ResponsiveSizing.getResponsiveHeight(
            context,
            heightPercent,
          ),
        );

        expect(result, 400);
      });

      testWidgets('최소 높이 제한 적용', (tester) async {
        final result = await _readPaddingValue<double>(
          tester,
          screenSize: const Size(400, 800),
          reader: (context) => ResponsiveSizing.getResponsiveHeight(
            context,
            0.1,
            minHeight: 100,
          ),
        );

        expect(result, 100);
      });

      testWidgets('최대 높이 제한 적용', (tester) async {
        final result = await _readPaddingValue<double>(
          tester,
          screenSize: const Size(400, 800),
          reader: (context) => ResponsiveSizing.getResponsiveHeight(
            context,
            0.8,
            maxHeight: 500,
          ),
        );

        expect(result, 500);
      });
    });

    group('getResponsiveWidth', () {
      testWidgets('화면 너비의 50% 반환', (tester) async {
        final result = await _readPaddingValue<double>(
          tester,
          screenSize: const Size(400, 800),
          reader: (context) => ResponsiveSizing.getResponsiveWidth(
            context,
            0.5,
          ),
        );

        expect(result, 200);
      });

      testWidgets('최소/최대 너비 제한 적용', (tester) async {
        final result = await _readPaddingValue<double>(
          tester,
          screenSize: const Size(400, 800),
          reader: (context) => ResponsiveSizing.getResponsiveWidth(
            context,
            0.1,
            minWidth: 100,
            maxWidth: 300,
          ),
        );

        expect(result, 100);
      });
    });

    group('getValueByDevice', () {
      testWidgets('모바일에서 mobile 값 반환', (tester) async {
        final result = await _readPaddingValue<double>(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          reader: (context) => ResponsiveSizing.getValueByDevice(
            context,
            mobile: 16,
            tablet: 20,
          ),
        );

        expect(result, 16);
      });

      testWidgets('태블릿에서 tablet 값 반환', (tester) async {
        final result = await _readPaddingValue<double>(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          reader: (context) => ResponsiveSizing.getValueByDevice(
            context,
            mobile: 16,
            tablet: 20,
          ),
        );

        expect(result, 20);
      });
    });
  });
}

Future<T> _readPaddingValue<T>(
    WidgetTester tester, {
      required Size screenSize,
      required T Function(BuildContext context) reader,
    }) async {
  T? value;
  await tester.pumpWidget(
    TestWrappersUtil.withScreenSize(
      Builder(
        builder: (context) {
          value = reader(context);
          return const SizedBox();
        },
      ),
      screenSize: screenSize,
    ),
  );

  return value!;
}
