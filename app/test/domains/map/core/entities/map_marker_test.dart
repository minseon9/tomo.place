import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:tomo_place/domains/map/core/entities/map_marker.dart';

void main() {
  group('MapMarker', () {
    const testId = 'test_marker_id';
    const testLatitude = 37.579617;
    const testLongitude = 126.977041;
    const testTitle = 'Test Marker';
    const testSnippet = 'Test Snippet';
    late LatLng testPosition;
    late BitmapDescriptor testIcon;

    setUp(() {
      testPosition = const LatLng(testLatitude, testLongitude);
      testIcon = BitmapDescriptor.defaultMarker;
    });

    test('should create MapMarker with required parameters', () {
      // When
      final marker = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );

      // Then
      expect(marker.id, equals(testId));
      expect(marker.position, equals(testPosition));
      expect(marker.title, equals(testTitle));
      expect(marker.snippet, equals(testSnippet));
      expect(marker.icon, isNull);
    });

    test('should create MapMarker with icon', () {
      // When
      final marker = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
        icon: testIcon,
      );

      // Then
      expect(marker.id, equals(testId));
      expect(marker.position, equals(testPosition));
      expect(marker.title, equals(testTitle));
      expect(marker.snippet, equals(testSnippet));
      expect(marker.icon, equals(testIcon));
    });

    test('should convert to Google Maps Marker correctly', () {
      // Given
      final marker = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );

      // When
      final googleMarker = marker.toGoogleMarker();

      // Then
      expect(googleMarker.markerId, equals(MarkerId(testId)));
      expect(googleMarker.position, equals(testPosition));
      expect(googleMarker.infoWindow.title, equals(testTitle));
      expect(googleMarker.infoWindow.snippet, equals(testSnippet));
      expect(googleMarker.icon, equals(BitmapDescriptor.defaultMarker));
    });

    test('should convert to Google Maps Marker with custom icon', () {
      // Given
      final marker = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
        icon: testIcon,
      );

      // When
      final googleMarker = marker.toGoogleMarker();

      // Then
      expect(googleMarker.markerId, equals(MarkerId(testId)));
      expect(googleMarker.position, equals(testPosition));
      expect(googleMarker.infoWindow.title, equals(testTitle));
      expect(googleMarker.infoWindow.snippet, equals(testSnippet));
      expect(googleMarker.icon, equals(testIcon));
    });

    test('should create copy with updated values', () {
      // Given
      final originalMarker = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );

      const newPosition = LatLng(37.5665, 126.9780);
      const newTitle = 'Updated Title';

      // When
      final updatedMarker = originalMarker.copyWith(
        position: newPosition,
        title: newTitle,
      );

      // Then
      expect(updatedMarker.id, equals(testId)); // unchanged
      expect(updatedMarker.position, equals(newPosition));
      expect(updatedMarker.title, equals(newTitle));
      expect(updatedMarker.snippet, equals(testSnippet)); // unchanged
    });

    test('should create copy with unchanged values when no parameters provided', () {
      // Given
      final originalMarker = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );

      // When
      final copiedMarker = originalMarker.copyWith();

      // Then
      expect(copiedMarker.id, equals(testId));
      expect(copiedMarker.position, equals(testPosition));
      expect(copiedMarker.title, equals(testTitle));
      expect(copiedMarker.snippet, equals(testSnippet));
    });

    test('should be equal when all properties are same', () {
      // Given
      final marker1 = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );
      final marker2 = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );

      // When & Then
      expect(marker1, equals(marker2));
      expect(marker1.hashCode, equals(marker2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Given
      final marker1 = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );
      final marker2 = MapMarker(
        id: 'different_id',
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );

      // When & Then
      expect(marker1, isNot(equals(marker2)));
    });

    test('should have correct string representation', () {
      // Given
      final marker = MapMarker(
        id: testId,
        position: testPosition,
        title: testTitle,
        snippet: testSnippet,
      );

      // When
      final stringRepresentation = marker.toString();

      // Then
      expect(stringRepresentation, contains('MapMarker'));
      expect(stringRepresentation, contains('id: $testId'));
      expect(stringRepresentation, contains('position: $testPosition'));
      expect(stringRepresentation, contains('title: $testTitle'));
    });
  });
}
