import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/map/core/usecases/move_to_location_usecase.dart';
import 'package:tomo_place/domains/map/core/repositories/map_repository.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  group('MoveToLocationUseCase', () {
    late MoveToLocationUseCase useCase;
    late MockMapRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(const MapPosition(latitude: 0, longitude: 0));
    });

    setUp(() {
      mockRepository = MockMapRepository();
      useCase = MoveToLocationUseCase(mockRepository);
    });

    group('execute', () {
      test('should move to specified position successfully', () async {
        // Given
        const position = MapPosition(
          latitude: 37.579617,
          longitude: 126.977041,
        );

        when(() => mockRepository.moveToPosition(position))
            .thenAnswer((_) async {});

        // When
        await useCase.execute(position);

        // Then
        verify(() => mockRepository.moveToPosition(position)).called(1);
      });

      test('should rethrow exception when moveToPosition fails', () async {
        // Given
        const position = MapPosition(
          latitude: 37.579617,
          longitude: 126.977041,
        );
        final exception = Exception('Move failed');

        when(() => mockRepository.moveToPosition(position))
            .thenThrow(exception);

        // When & Then
        expect(
          () => useCase.execute(position),
          throwsA(equals(exception)),
        );
        verify(() => mockRepository.moveToPosition(position)).called(1);
      });
    });

    group('moveToCurrentLocation', () {
      test('should move to current location when current position exists', () async {
        // Given
        const currentPosition = MapPosition(
          latitude: 37.579617,
          longitude: 126.977041,
        );

        when(() => mockRepository.getCurrentPosition())
            .thenAnswer((_) async => currentPosition);
        when(() => mockRepository.moveToPosition(currentPosition))
            .thenAnswer((_) async {});

        // When
        await useCase.moveToCurrentLocation();

        // Then
        verify(() => mockRepository.getCurrentPosition()).called(1);
        verify(() => mockRepository.moveToPosition(currentPosition)).called(1);
      });

      test('should not move when current position is null', () async {
        // Given
        when(() => mockRepository.getCurrentPosition())
            .thenAnswer((_) async => null);

        // When
        await useCase.moveToCurrentLocation();

        // Then
        verify(() => mockRepository.getCurrentPosition()).called(1);
        verifyNever(() => mockRepository.moveToPosition(any()));
      });

      test('should rethrow exception when getCurrentPosition fails', () async {
        // Given
        final exception = Exception('Get position failed');

        when(() => mockRepository.getCurrentPosition())
            .thenThrow(exception);

        // When & Then
        expect(
          () => useCase.moveToCurrentLocation(),
          throwsA(equals(exception)),
        );
        verify(() => mockRepository.getCurrentPosition()).called(1);
        verifyNever(() => mockRepository.moveToPosition(any()));
      });

      test('should rethrow exception when moveToPosition fails', () async {
        // Given
        const currentPosition = MapPosition(
          latitude: 37.579617,
          longitude: 126.977041,
        );
        final exception = Exception('Move failed');

        when(() => mockRepository.getCurrentPosition())
            .thenAnswer((_) async => currentPosition);
        when(() => mockRepository.moveToPosition(currentPosition))
            .thenThrow(exception);

        // When & Then
        expect(
          () => useCase.moveToCurrentLocation(),
          throwsA(equals(exception)),
        );
        verify(() => mockRepository.getCurrentPosition()).called(1);
        verifyNever(() => mockRepository.moveToPosition(currentPosition));
      });
    });
  });
}
