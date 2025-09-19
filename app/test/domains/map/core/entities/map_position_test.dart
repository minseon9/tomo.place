import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:tomo_place/domains/map/core/entities/map_position.dart';

void main() {
  group('MapPosition', () {
    const testLatitude = 37.579617;
    const testLongitude = 126.977041;
    const testZoom = 16.0;

    test('should create MapPosition with required parameters', () {
      // When
      const position = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );

      // Then
      expect(position.latitude, equals(testLatitude));
      expect(position.longitude, equals(testLongitude));
      expect(position.zoom, equals(testZoom));
    });

    test('should create MapPosition with default zoom', () {
      // When
      const position = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
      );

      // Then
      expect(position.latitude, equals(testLatitude));
      expect(position.longitude, equals(testLongitude));
      expect(position.zoom, equals(16.0)); // default zoom
    });

    test('should convert to LatLng correctly', () {
      // Given
      const position = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
      );

      // When
      final latLng = position.toLatLng();

      // Then
      expect(latLng.latitude, equals(testLatitude));
      expect(latLng.longitude, equals(testLongitude));
    });

    test('should convert to CameraPosition correctly', () {
      // Given
      const position = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );

      // When
      final cameraPosition = position.toCameraPosition();

      // Then
      expect(cameraPosition.target.latitude, equals(testLatitude));
      expect(cameraPosition.target.longitude, equals(testLongitude));
      expect(cameraPosition.zoom, equals(testZoom));
    });

    test('should create copy with updated values', () {
      // Given
      const originalPosition = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );

      // When
      final updatedPosition = originalPosition.copyWith(
        latitude: 37.5665,
        zoom: 18.0,
      );

      // Then
      expect(updatedPosition.latitude, equals(37.5665));
      expect(updatedPosition.longitude, equals(testLongitude)); // unchanged
      expect(updatedPosition.zoom, equals(18.0));
    });

    test('should create copy with unchanged values when no parameters provided', () {
      // Given
      const originalPosition = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );

      // When
      final copiedPosition = originalPosition.copyWith();

      // Then
      expect(copiedPosition.latitude, equals(testLatitude));
      expect(copiedPosition.longitude, equals(testLongitude));
      expect(copiedPosition.zoom, equals(testZoom));
    });

    test('should be equal when all properties are same', () {
      // Given
      const position1 = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );
      const position2 = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );

      // When & Then
      expect(position1, equals(position2));
      expect(position1.hashCode, equals(position2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Given
      const position1 = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );
      const position2 = MapPosition(
        latitude: 37.5665,
        longitude: testLongitude,
        zoom: testZoom,
      );

      // When & Then
      expect(position1, isNot(equals(position2)));
    });

    test('should have correct string representation', () {
      // Given
      const position = MapPosition(
        latitude: testLatitude,
        longitude: testLongitude,
        zoom: testZoom,
      );

      // When
      final stringRepresentation = position.toString();

      // Then
      expect(stringRepresentation, contains('MapPosition'));
      expect(stringRepresentation, contains('lat: $testLatitude'));
      expect(stringRepresentation, contains('lng: $testLongitude'));
      expect(stringRepresentation, contains('zoom: $testZoom'));
    });
  });
}
