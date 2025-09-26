import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/typography.dart';
import 'package:tomo_place/shared/ui/responsive/device_type.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_typography.dart';

import '../../../utils/test_responsive_util.dart';
import '../../../utils/test_wrappers_util.dart';
import '../../../utils/verifiers/test_style_verifier.dart';


void main() {
  group('ResponsiveTypography', () {
    group('getResponsiveTextStyle', () {
      const baseStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
      const text = Text("TEST", style: baseStyle);

      testWidgets('applies mobile multiplier', (tester) async {
        await tester.pumpWidget(
            TestWrappersUtil.withScreenSize(
              text,
              screenSize: TestResponsiveUtil.standardMobileSize,
            ),
        );

        final expected = TestResponsiveUtil.expectedFontSize(baseStyle.fontSize, DeviceType.mobile);
        TestStyleVerifier.expectTextStyle(
          tester,
          text.data!,
          fontSize: expected,
          fontWeight: FontWeight.w600,
        );
      });

      testWidgets('applies tablet multiplier', (tester) async {
        await tester.pumpWidget(
          TestWrappersUtil.withScreenSize(
            text,
            screenSize: TestResponsiveUtil.standardTabletSize,
          ),
        );

        final expected = TestResponsiveUtil.expectedFontSize(baseStyle.fontSize, DeviceType.tablet);
        TestStyleVerifier.expectTextStyle(
          tester,
          text.data!,
          fontSize: expected,
          fontWeight: FontWeight.w600,
        );
      });

      testWidgets('defaults to 16 when fontSize is null', (tester) async {
        const base = TextStyle(fontWeight: FontWeight.bold);
        const text = Text("TEST", style: base);

        await tester.pumpWidget(
          TestWrappersUtil.withScreenSize(
            text,
            screenSize: TestResponsiveUtil.standardMobileSize,
          ),
        );

        final expected = TestResponsiveUtil.expectedFontSize(16, DeviceType.mobile);
        TestStyleVerifier.expectTextStyle(
          tester,
          text.data!,
          fontSize: expected,
          fontWeight: FontWeight.bold,
        );
      });
    });

    Future<void> _expectTypographyMethod(
      WidgetTester tester, {
      required Size screenSize,
      required TextStyle baseStyle,
      required DeviceType deviceType,
      required TextStyle Function(BuildContext) method,
    }) async {
      final text = Text("TEST", style: baseStyle);
      await tester.pumpWidget(
        TestWrappersUtil.withScreenSize(
          text,
          screenSize: screenSize,
        ),
      );

      final expected = TestResponsiveUtil.expectedFontSize(baseStyle.fontSize, deviceType);
      TestStyleVerifier.expectTextStyle(
        tester,
        text.data!,
        fontSize: expected,
        fontWeight: baseStyle.fontWeight,
      );
    }

    group('typography shortcuts', () {
      testWidgets('header1 - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.header1,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveHeader1(context),
        );
      });

      testWidgets('header1 - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.header1,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveHeader1(context),
        );
      });

      testWidgets('header2 - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.header2,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveHeader2(context),
        );
      });

      testWidgets('header2 - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.header2,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveHeader2(context),
        );
      });

      testWidgets('header3 - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.header3,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveHeader3(context),
        );
      });

      testWidgets('header3 - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.header3,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveHeader3(context),
        );
      });

      testWidgets('head3 - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.head3,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveHead3(context),
        );
      });

      testWidgets('head3 - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.head3,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveHead3(context),
        );
      });

      testWidgets('body - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.body,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveBody(context),
        );
      });

      testWidgets('body - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.body,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveBody(context),
        );
      });

      testWidgets('button - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.button,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveButton(context),
        );
      });

      testWidgets('button - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.button,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveButton(context),
        );
      });

      testWidgets('caption - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.caption,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveCaption(context),
        );
      });

      testWidgets('caption - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.caption,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveCaption(context),
        );
      });

      testWidgets('bold - mobile', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardMobileSize,
          baseStyle: AppTypography.bold,
          deviceType: DeviceType.mobile,
          method: (context) => ResponsiveTypography.getResponsiveBold(context),
        );
      });

      testWidgets('bold - tablet', (tester) async {
        await _expectTypographyMethod(
          tester,
          screenSize: TestResponsiveUtil.standardTabletSize,
          baseStyle: AppTypography.bold,
          deviceType: DeviceType.tablet,
          method: (context) => ResponsiveTypography.getResponsiveBold(context),
        );
      });
    });
  });
}
