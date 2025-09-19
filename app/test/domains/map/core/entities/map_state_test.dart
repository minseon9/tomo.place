import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/map/presentation/models/map_state.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';
import '../../../../utils/mock_factory/map_mock_factory.dart';

void main() {
  group('MapState', () {
    const testLatitude = 37.579617;
    const testLongitude = 126.977041;
    late LatLng testPosition;
    late MockExceptionInterface mockException;

    setUp(() {
      testPosition = const LatLng(testLatitude, testLongitude);
      mockException = MockExceptionInterface();
      when(() => mockException.message).thenReturn('Test error');
      when(() => mockException.userMessage).thenReturn('Test user error');
    });

    group('MapInitial', () {
      test('should create MapInitial state', () {
        // When
        const state = MapInitial();

        // Then
        expect(state, isA<MapState>());
        expect(state.props, isEmpty);
      });
    });

    group('MapLoading', () {
      test('should create MapLoading state', () {
        // When
        const state = MapLoading();

        // Then
        expect(state, isA<MapState>());
        expect(state.props, isEmpty);
      });
    });

    group('MapReady', () {
      test('should create MapReady state with current position', () {
        // When
        final state = MapReady(currentPosition: testPosition);

        // Then
        expect(state, isA<MapState>());
        expect(state.currentPosition, equals(testPosition));
        expect(state.props, equals([testPosition]));
      });
    });

    group('MapError', () {
      test('should create MapError state with exception', () {
        // When
        final state = MapError(error: mockException);

        // Then
        expect(state, isA<MapState>());
        expect(state.error, equals(mockException));
        expect(state.props, equals([mockException]));
      });
    });

    group('equality', () {
      test('should be equal when same state type and properties', () {
        // Given
        final state1 = MapReady(currentPosition: testPosition);
        final state2 = MapReady(currentPosition: testPosition);

        // When & Then
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when different state types', () {
        // Given
        const state1 = MapInitial();
        const state2 = MapLoading();

        // When & Then
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when different properties', () {
        // Given
        final position1 = const LatLng(37.579617, 126.977041);
        final position2 = const LatLng(37.566535, 126.977969);
        final state1 = MapReady(currentPosition: position1);
        final state2 = MapReady(currentPosition: position2);

        // When & Then
        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
