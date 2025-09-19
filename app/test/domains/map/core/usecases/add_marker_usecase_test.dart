import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:tomo_place/domains/map/core/usecases/add_marker_usecase.dart';
import 'package:tomo_place/domains/map/core/repositories/map_repository.dart';
import 'package:tomo_place/domains/map/core/entities/map_marker.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  group('AddMarkerUseCase', () {
    late AddMarkerUseCase useCase;
    late MockMapRepository mockRepository;

    setUp(() {
      mockRepository = MockMapRepository();
      useCase = AddMarkerUseCase(mockRepository);
    });

    group('execute', () {
      test('should add marker successfully', () async {
        // Given
        const marker = MapMarker(
          id: 'test_marker',
          position: LatLng(37.579617, 126.977041),
          title: 'Test Marker',
        );

        when(() => mockRepository.addMarker(marker))
            .thenAnswer((_) async {});

        // When
        await useCase.execute(marker);

        // Then
        verify(() => mockRepository.addMarker(marker)).called(1);
      });

      test('should rethrow exception when addMarker fails', () async {
        // Given
        const marker = MapMarker(
          id: 'test_marker',
          position: LatLng(37.579617, 126.977041),
        );
        final exception = Exception('Add marker failed');

        when(() => mockRepository.addMarker(marker))
            .thenThrow(exception);

        // When & Then
        expect(
          () => useCase.execute(marker),
          throwsA(equals(exception)),
        );
        verify(() => mockRepository.addMarker(marker)).called(1);
      });
    });

    group('removeMarker', () {
      test('should remove marker successfully', () async {
        // Given
        const markerId = 'test_marker';

        when(() => mockRepository.removeMarker(markerId))
            .thenAnswer((_) async {});

        // When
        await useCase.removeMarker(markerId);

        // Then
        verify(() => mockRepository.removeMarker(markerId)).called(1);
      });

      test('should rethrow exception when removeMarker fails', () async {
        // Given
        const markerId = 'test_marker';
        final exception = Exception('Remove marker failed');

        when(() => mockRepository.removeMarker(markerId))
            .thenThrow(exception);

        // When & Then
        expect(
          () => useCase.removeMarker(markerId),
          throwsA(equals(exception)),
        );
        verify(() => mockRepository.removeMarker(markerId)).called(1);
      });
    });

    group('clearAllMarkers', () {
      test('should clear all markers successfully', () async {
        // Given
        when(() => mockRepository.clearMarkers())
            .thenAnswer((_) async {});

        // When
        await useCase.clearAllMarkers();

        // Then
        verify(() => mockRepository.clearMarkers()).called(1);
      });

      test('should rethrow exception when clearMarkers fails', () async {
        // Given
        final exception = Exception('Clear markers failed');

        when(() => mockRepository.clearMarkers())
            .thenThrow(exception);

        // When & Then
        expect(
          () => useCase.clearAllMarkers(),
          throwsA(equals(exception)),
        );
        verify(() => mockRepository.clearMarkers()).called(1);
      });
    });
  });
}
