import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tomo_place/domains/map/presentation/controllers/map_notifier.dart';
import 'package:tomo_place/domains/map/presentation/models/map_state.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/domains/map/data/map/map_renderer.dart';

import 'base_state_notifier_mock_factory.dart';

/// MapNotifier Mock 클래스
class MockMapNotifier extends StateNotifier<MapState> implements MapNotifier {
  MockMapNotifier() : super(const MapInitial());

  @override
  Future<void> initializeMap() async {
    // Mock 구현: 로딩 완료 상태로 설정
    state = const MapReady(currentPosition: LatLng(37.579617, 126.977041)); // 서울 경복궁 좌표
  }

  @override
  void setMapController(MapController controller) {
    // Mock 구현: 아무것도 하지 않음
  }

  @override
  Future<void> moveToCurrentLocation() async {
    // Mock 구현: 아무것도 하지 않음
  }

  @override
  Ref get _ref => throw UnimplementedError('Mock에서는 사용하지 않음');

  @override
  ExceptionNotifier get _effects => throw UnimplementedError('Mock에서는 사용하지 않음');
}

/// Mock MapState 생성 함수들
MapState createMockMapState({
  LatLng? currentPosition,
}) {
  return MapReady(currentPosition: currentPosition ?? const LatLng(37.579617, 126.977041));
}

/// 로딩 상태의 Mock MapState
MapState createLoadingMapState() {
  return const MapLoading();
}

/// 초기화 완료된 Mock MapState
MapState createInitializedMapState() {
  return const MapReady(currentPosition: LatLng(37.579617, 126.977041));
}

/// MapNotifier Mock 팩토리 클래스
class MapNotifierMockFactory {
  MapNotifierMockFactory._();

  /// Mock MapNotifier 생성
  static MockMapNotifier createMapNotifier() => MockMapNotifier();

  /// Mock Provider 생성
  static Provider<MapNotifier> createMockProvider() {
    return BaseStateNotifierMockFactory.createMockProvider(() => createMapNotifier());
  }

  /// Provider Override 생성
  static List<Override> createOverrides(Provider<MapNotifier> provider) {
    return BaseStateNotifierMockFactory.createOverrides(provider, createMapNotifier());
  }
}
