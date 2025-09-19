import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/map/core/usecases/get_current_location_usecase.dart';
import 'package:tomo_place/domains/map/core/repositories/location_repository.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  group('GetCurrentLocationUseCase', () {
    late GetCurrentLocationUseCase useCase;
    late MockLocationRepository mockRepository;

    setUp(() {
      mockRepository = MockLocationRepository();
      useCase = GetCurrentLocationUseCase(mockRepository);
    });

    group('execute', () {
      test('should return current position when location service is enabled and permission is granted', () async {
        // Given
        const expectedPosition = MapPosition(
          latitude: 37.579617,
          longitude: 126.977041,
        );

        when(() => mockRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockRepository.requestLocationPermission())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getCurrentLocation())
            .thenAnswer((_) async => expectedPosition);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, equals(expectedPosition));
        verify(() => mockRepository.isLocationServiceEnabled()).called(1);
        verify(() => mockRepository.requestLocationPermission()).called(1);
        verify(() => mockRepository.getCurrentLocation()).called(1);
      });

      test('should return null when location service is disabled', () async {
        // Given
        when(() => mockRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => false);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isNull);
        verify(() => mockRepository.isLocationServiceEnabled()).called(1);
        verifyNever(() => mockRepository.requestLocationPermission());
        verifyNever(() => mockRepository.getCurrentLocation());
      });

      test('should return null when location permission is denied', () async {
        // Given
        when(() => mockRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockRepository.requestLocationPermission())
            .thenAnswer((_) async => false);

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isNull);
        verify(() => mockRepository.isLocationServiceEnabled()).called(1);
        verify(() => mockRepository.requestLocationPermission()).called(1);
        verifyNever(() => mockRepository.getCurrentLocation());
      });

      test('should return null when getCurrentLocation throws exception', () async {
        // Given
        when(() => mockRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockRepository.requestLocationPermission())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getCurrentLocation())
            .thenThrow(Exception('Location error'));

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isNull);
        verify(() => mockRepository.isLocationServiceEnabled()).called(1);
        verify(() => mockRepository.requestLocationPermission()).called(1);
        verify(() => mockRepository.getCurrentLocation()).called(1);
      });

      test('should return null when isLocationServiceEnabled throws exception', () async {
        // Given
        when(() => mockRepository.isLocationServiceEnabled())
            .thenThrow(Exception('Service error'));

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isNull);
        verify(() => mockRepository.isLocationServiceEnabled()).called(1);
        verifyNever(() => mockRepository.requestLocationPermission());
        verifyNever(() => mockRepository.getCurrentLocation());
      });

      test('should return null when requestLocationPermission throws exception', () async {
        // Given
        when(() => mockRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockRepository.requestLocationPermission())
            .thenThrow(Exception('Permission error'));

        // When
        final result = await useCase.execute();

        // Then
        expect(result, isNull);
        verify(() => mockRepository.isLocationServiceEnabled()).called(1);
        verify(() => mockRepository.requestLocationPermission()).called(1);
        verifyNever(() => mockRepository.getCurrentLocation());
      });
    });
  });
}
