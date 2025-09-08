import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/shared/config/app_config.dart';
import 'package:tomo_place/shared/config/env_config.dart';

// Mock EnvConfigInterface
class MockEnvConfigInterface extends Mock implements EnvConfigInterface {}

void main() {
  group('AppConfig', () {
    late MockEnvConfigInterface mockEnvConfig;
    late ProviderContainer container;

    setUp(() {
      mockEnvConfig = MockEnvConfigInterface();
      container = ProviderContainer(
        overrides: [
          envConfigProvider.overrideWithValue(mockEnvConfig),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('initialize', () {
      test('should call EnvConfig.initialize', () async {
        // Arrange
        when(() => mockEnvConfig.initialize()).thenAnswer((_) async {});

        // Act
        final appConfig = container.read(appConfigProvider);
        await appConfig.initialize();

        // Assert
        verify(() => mockEnvConfig.initialize()).called(1);
      });

      test('should handle initialization errors', () async {
        // Arrange
        when(() => mockEnvConfig.initialize()).thenThrow(Exception('Initialization failed'));

        // Act
        final appConfig = container.read(appConfigProvider);

        // Assert
        expect(
          () => appConfig.initialize(),
          throwsA(isA<Exception>()),
        );
      });

      test('should be idempotent', () async {
        // Arrange
        when(() => mockEnvConfig.initialize()).thenAnswer((_) async {});

        // Act
        final appConfig = container.read(appConfigProvider);
        await appConfig.initialize();
        await appConfig.initialize();

        // Assert
        verify(() => mockEnvConfig.initialize()).called(2);
      });
    });

    group('apiUrl', () {
      test('should return EnvConfig.apiUrl when _apiUrl is null', () {
        // Arrange
        when(() => mockEnvConfig.apiUrl).thenReturn('https://env.api.com');

        // Act
        final appConfig = container.read(appConfigProvider);
        final result = appConfig.apiUrl;

        // Assert
        expect(result, equals('https://env.api.com'));
      });

      test('should handle different API URLs', () {
        // Arrange
        when(() => mockEnvConfig.apiUrl).thenReturn('https://test.api.com');

        // Act
        final appConfig = container.read(appConfigProvider);
        final result = appConfig.apiUrl;

        // Assert
        expect(result, equals('https://test.api.com'));
      });

      test('should be consistent across multiple calls', () {
        // Arrange
        when(() => mockEnvConfig.apiUrl).thenReturn('https://consistent.api.com');

        // Act
        final appConfig = container.read(appConfigProvider);
        final result1 = appConfig.apiUrl;
        final result2 = appConfig.apiUrl;

        // Assert
        expect(result1, equals(result2));
        expect(result1, equals('https://consistent.api.com'));
      });

      test('should handle special characters in URLs', () {
        // Arrange
        const specialUrl = 'https://api.test.com/path?param=value&other=123';
        when(() => mockEnvConfig.apiUrl).thenReturn(specialUrl);

        // Act
        final appConfig = container.read(appConfigProvider);
        final result = appConfig.apiUrl;

        // Assert
        expect(result, equals(specialUrl));
      });
    });

    group('appConfigProvider', () {
      test('should provide AppConfig instance', () {
        // Act
        final appConfig = container.read(appConfigProvider);

        // Assert
        expect(appConfig, isA<AppConfig>());
      });

      test('should return same instance on multiple calls', () {
        // Act
        final appConfig1 = container.read(appConfigProvider);
        final appConfig2 = container.read(appConfigProvider);

        // Assert
        expect(identical(appConfig1, appConfig2), isTrue);
      });

      test('should be disposable', () {
        // Act
        container.dispose();

        // Assert - should not throw
        expect(() => container.dispose(), returnsNormally);
      });

      test('should work with ProviderScope', () {
        // Arrange
        final container = ProviderContainer();

        // Act
        final appConfig = container.read(appConfigProvider);

        // Assert
        expect(appConfig, isA<AppConfig>());
      });
    });

    group('integration', () {
      test('should work after initialization', () async {
        // Arrange
        when(() => mockEnvConfig.initialize()).thenAnswer((_) async {});
        when(() => mockEnvConfig.apiUrl).thenReturn('https://integration.api.com');

        // Act
        final appConfig = container.read(appConfigProvider);
        await appConfig.initialize();
        final apiUrl = appConfig.apiUrl;

        // Assert
        expect(apiUrl, equals('https://integration.api.com'));
        verify(() => mockEnvConfig.initialize()).called(1);
      });

      test('should handle multiple initialization calls', () async {
        // Arrange
        when(() => mockEnvConfig.initialize()).thenAnswer((_) async {});

        // Act
        final appConfig = container.read(appConfigProvider);
        await appConfig.initialize();
        await appConfig.initialize();
        await appConfig.initialize();

        // Assert
        verify(() => mockEnvConfig.initialize()).called(3);
      });
    });
  });
}
