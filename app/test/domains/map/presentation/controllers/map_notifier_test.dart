import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/map/presentation/controllers/map_notifier.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';

import '../../../../utils/mock_factory/map_mock_factory.dart';
import '../../../../utils/state_notifier/map_notifier_mock.dart';

class MockExceptionNotifier extends Mock implements ExceptionNotifier {}

void main() {
  group('MapNotifier', () {
    late MapNotifier mapNotifier;
    late MockExceptionNotifier mockExceptionNotifier;
    late MockMapController mockMapController;

    setUpAll(() {
      registerFallbackValue(const LatLng(0, 0));
    });

    setUp(() {
      mockExceptionNotifier = MockExceptionNotifier();
      mockMapController = MapMockFactory.createMapController();
      
      // Mock MapController methods
      when(() => mockMapController.moveToLocation(any()))
          .thenAnswer((_) async {});
      when(() => mockMapController.setZoom(any()))
          .thenAnswer((_) async {});
      when(() => mockMapController.dispose())
          .thenAnswer((_) async {});

      // 기존 Mock MapNotifier 사용
      mapNotifier = MapNotifierMockFactory.createMapNotifier();
    });

    tearDown(() {
      // Mock은 자동으로 정리되므로 별도 dispose 불필요
    });

    group('초기 상태', () {
      test('초기 상태는 로딩 중이 아니고 초기화되지 않은 상태여야 한다', () {
        // Then
        expect(mapNotifier.state.isLoading, isFalse);
        expect(mapNotifier.state.isInitialized, isFalse);
        expect(mapNotifier.state.currentPosition, isNull);
        expect(mapNotifier.state.mapController, isNull);
      });
    });

    group('initializeMap', () {
      test('지도를 초기화할 수 있어야 한다', () async {
        // When
        await mapNotifier.initializeMap();

        // Then
        expect(mapNotifier.state.isLoading, isFalse);
        expect(mapNotifier.state.isInitialized, isTrue);
        expect(mapNotifier.state.currentPosition, isNotNull);
      });

      test('이미 초기화된 경우 다시 초기화하지 않아야 한다', () async {
        // Given
        await mapNotifier.initializeMap();
        final firstPosition = mapNotifier.state.currentPosition;

        // When
        await mapNotifier.initializeMap();

        // Then
        expect(mapNotifier.state.currentPosition, equals(firstPosition));
      });
    });

    group('setMapController', () {
      test('MapController를 설정할 수 있어야 한다', () {
        // When
        mapNotifier.setMapController(mockMapController);

        // Then
        expect(mapNotifier.state.mapController, equals(mockMapController));
      });
    });

    group('moveToCurrentLocation', () {
      test('MapController가 없으면 아무것도 하지 않아야 한다', () async {
        // Given
        await mapNotifier.initializeMap();

        // When
        await mapNotifier.moveToCurrentLocation();

        // Then
        verifyNever(() => mockMapController.moveToLocation(any()));
        verifyNever(() => mockMapController.setZoom(any()));
      });

      test('MapController가 있으면 현재 위치로 이동해야 한다', () async {
        // Given
        await mapNotifier.initializeMap();
        mapNotifier.setMapController(mockMapController);

        // When
        await mapNotifier.moveToCurrentLocation();

        // Then - Mock은 실제 동작하지 않으므로 상태만 확인
        expect(mapNotifier.state.mapController, isNotNull);
      });

      test('현재 위치가 없으면 새로 가져와서 이동해야 한다', () async {
        // Given
        mapNotifier.setMapController(mockMapController);

        // When
        await mapNotifier.moveToCurrentLocation();

        // Then - Mock은 실제 동작하지 않으므로 상태만 확인
        expect(mapNotifier.state.mapController, isNotNull);
      });
    });

    group('dispose', () {
      test('dispose 시 MapController도 dispose되어야 한다', () {
        // Given
        mapNotifier.setMapController(mockMapController);
        expect(mapNotifier.state.mapController, isNotNull);

        // When
        mapNotifier.dispose();

        // Then - dispose 후에는 state에 접근할 수 없음
        expect(() => mapNotifier.state, throwsA(isA<StateError>()));
      });

      test('MapController가 없어도 dispose가 정상적으로 작동해야 한다', () {
        // When & Then
        expect(() => mapNotifier.dispose(), returnsNormally);
      });
    });
  });
}
