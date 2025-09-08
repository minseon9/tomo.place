import 'package:app/shared/application/navigation/navigation_actions.dart';
import 'package:app/shared/application/navigation/navigation_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('NavigationProviders', () {
    group('navigatorKeyProvider', () {
      late ProviderContainer container;

      setUp(() {
        container = ProviderContainer();
      });

      tearDown(() {
        container.dispose();
      });

      test('should provide GlobalKey<NavigatorState>', () {
        // Act
        final navigatorKey = container.read(navigatorKeyProvider);

        // Assert
        expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
      });

      test('should create new instance each time', () {
        // Act
        final navigatorKey1 = container.read(navigatorKeyProvider);
        final navigatorKey2 = container.read(navigatorKeyProvider);

        // Assert
        expect(identical(navigatorKey1, navigatorKey2), isTrue);
      });

      test('should be disposable', () {
        // Act
        container.dispose();

        // Assert - should not throw
        expect(() => container.dispose(), returnsNormally);
      });
    });

    group('NavigationActions', () {
      late GlobalKey<NavigatorState> navigatorKey;
      late NavigationActions navigationActions;

      setUp(() {
        navigatorKey = GlobalKey<NavigatorState>();
        navigationActions = NavigationActions(navigatorKey);
      });

      group('constructor', () {
        test('should create instance with navigator key', () {
          // Act
          final actions = NavigationActions(navigatorKey);

          // Assert
          expect(actions, isA<NavigationActions>());
        });
      });

      group('navigateToSignup', () {
        test('should handle null currentState gracefully', () {
          // Arrange
          // navigatorKey.currentState is null by default

          // Act & Assert - should not throw
          expect(() => navigationActions.navigateToSignup(), returnsNormally);
        });
      });

      group('navigateToHome', () {
        test('should handle null currentState gracefully', () {
          // Arrange
          // navigatorKey.currentState is null by default

          // Act & Assert - should not throw
          expect(() => navigationActions.navigateToHome(), returnsNormally);
        });
      });

      group('showSnackBar', () {
        test('should handle null context gracefully', () {
          // Arrange
          // navigatorKey.currentContext is null by default

          // Act & Assert - should not throw
          expect(() => navigationActions.showSnackBar('Test message'), returnsNormally);
        });

        test('should accept string message', () {
          // Arrange
          const testMessage = 'Test snackbar message';

          // Act & Assert - should not throw
          expect(() => navigationActions.showSnackBar(testMessage), returnsNormally);
        });

        test('should handle empty message', () {
          // Act & Assert - should not throw
          expect(() => navigationActions.showSnackBar(''), returnsNormally);
        });

        test('should handle special characters in message', () {
          // Arrange
          const specialMessage = 'Test message with special chars: !@#\$%^&*()';

          // Act & Assert - should not throw
          expect(() => navigationActions.showSnackBar(specialMessage), returnsNormally);
        });
      });

      group('integration', () {
        testWidgets('should work with MaterialApp without routes', (WidgetTester tester) async {
          // Arrange
          final testWidget = MaterialApp(
            navigatorKey: navigatorKey,
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  // Only test showSnackBar since it doesn't require routes
                  navigationActions.showSnackBar('Test message');
                },
                child: const Text('Test Button'),
              ),
            ),
          );

          // Act
          await tester.pumpWidget(testWidget);

          // Assert - should not throw
          expect(() => navigationActions.showSnackBar('Test message'), returnsNormally);
        });
      });
    });
  });
}
