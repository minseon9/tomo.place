import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';

import 'package:tomo_place/shared/ui/responsive/device_type.dart';
import 'package:tomo_place/shared/ui/responsive/responsive_config.dart';

void main() {
  group('ResponsiveConfig', () {
    group('getDeviceType', () {
      test('모바일 브레이크포인트 미만에서 mobile 반환', () {
        // Given
        const width = 599.0;

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.mobile));
      });

      test('모바일 브레이크포인트에서 tablet 반환', () {
        // Given
        const width = 600.0;

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.tablet));
      });

      test('모바일 브레이크포인트 초과에서 tablet 반환', () {
        // Given
        const width = 601.0;

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.tablet));
      });

      test('태블릿 브레이크포인트에서 tablet 반환', () {
        // Given
        const width = 1024.0;

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.tablet));
      });

      test('태블릿 브레이크포인트 초과에서 tablet 반환', () {
        // Given
        const width = 1025.0;

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.tablet));
      });

      test('경계값 테스트 - 0px', () {
        // Given
        const width = 0.0;

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.mobile));
      });

      test('경계값 테스트 - 매우 큰 값', () {
        // Given
        const width = 9999.0;

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.tablet));
      });

      test('랜덤 모바일 크기에서 mobile 반환', () {
        // Given
        final width = faker.randomGenerator.integer(599, min: 0).toDouble();

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.mobile));
      });

      test('랜덤 태블릿 크기에서 tablet 반환', () {
        // Given
        final width = faker.randomGenerator.integer(2000, min: 600).toDouble();

        // When
        final result = ResponsiveConfig.getDeviceType(width);

        // Then
        expect(result, equals(DeviceType.tablet));
      });
    });

    group('브레이크포인트 상수', () {
      test('mobileBreakpoint가 600인지 확인', () {
        expect(ResponsiveConfig.mobileBreakpoint, equals(600.0));
      });

      test('tabletBreakpoint가 1024인지 확인', () {
        expect(ResponsiveConfig.tabletBreakpoint, equals(1024.0));
      });
    });
  });
}

