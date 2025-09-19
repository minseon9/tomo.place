import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/map/core/repositories/location_repository.dart';
import 'package:tomo_place/domains/map/core/services/map_controller_service.dart';
import 'package:tomo_place/domains/map/core/usecases/get_current_location_usecase.dart';
import 'package:tomo_place/domains/map/core/usecases/move_to_location_usecase.dart';
import 'package:tomo_place/domains/map/data/map/map_renderer.dart';
import 'package:tomo_place/domains/map/presentation/controllers/map_notifier.dart';
import 'package:tomo_place/domains/map/presentation/providers/map_providers.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';
import '../state_notifier/map_notifier_mock.dart';

/// Map Domain Mock 클래스들
class MockMapRenderer extends Mock implements MapRenderer {}

class MockMapController extends Mock implements MapController {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockMapControllerService extends Mock implements MapControllerService {}

class MockGetCurrentLocationUseCase extends Mock implements GetCurrentLocationUseCase {}

class MockMoveToLocationUseCase extends Mock implements MoveToLocationUseCase {}

class MockExceptionInterface extends Mock implements ExceptionInterface {}

/// Map Domain Mock 객체 생성을 위한 팩토리 클래스
class MapMockFactory {
  MapMockFactory._();

  // Service Mocks
  static MockLocationRepository createLocationRepository() => MockLocationRepository();
  static MockMapControllerService createMapControllerService() => MockMapControllerService();

  // UseCase Mocks
  static MockGetCurrentLocationUseCase createGetCurrentLocationUseCase() => MockGetCurrentLocationUseCase();
  static MockMoveToLocationUseCase createMoveToLocationUseCase() => MockMoveToLocationUseCase();

  // Renderer Mocks
  static MockMapRenderer createMapRenderer() => MockMapRenderer();
  static MockMapController createMapController() => MockMapController();

  // Exception Mocks
  static MockExceptionInterface createExceptionInterface() => MockExceptionInterface();

  // Presentation Mocks - 기존 Mock 클래스 사용
  static MockMapNotifier createMapNotifier() => MapNotifierMockFactory.createMapNotifier();

  /// MapRenderer Provider Override 헬퍼
  /// 
  /// 테스트에서 쉽게 Mock MapRenderer를 사용할 수 있도록 도와주는 헬퍼 함수입니다.
  /// 
  /// 사용 예시:
  /// ```dart
  /// testWidgets('test', (tester) async {
  ///   await tester.pumpWidget(
  ///     ProviderScope(
  ///       overrides: MapMockFactory.createMapRendererOverrides(),
  ///       child: MyApp(),
  ///     ),
  ///   );
  /// });
  /// ```
  static List<Override> createMapRendererOverrides() {
    return [
      mapRendererProvider.overrideWith((ref) => createMapRenderer()),
    ];
  }

  /// 모든 Map 관련 Provider Override 헬퍼
  static List<Override> createAllMapOverrides() {
    return [
      ...createMapRendererOverrides(),
    ];
  }
}
