import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tomo_place/domains/home/presentation/controller/map_notifier.dart';
import 'package:tomo_place/domains/home/presentation/models/map_state.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';

import 'base_state_notifier_mock_factory.dart';

/// MapNotifier Mock 클래스
class MockMapNotifier extends StateNotifier<MapState> implements MapNotifier {
  MockMapNotifier() : super(const MapState(
    isLoading: false,
    isInitialized: true,
    currentPosition: LatLng(37.579617, 126.977041), // 서울 경복궁 좌표
  ));

  @override
  Future<void> initializeMap() async {
    // Mock 구현: 로딩 완료 상태로 설정
    state = const MapState(
      isLoading: false,
      isInitialized: true,
      currentPosition: LatLng(37.579617, 126.977041), // 서울 경복궁 좌표
    );
  }

  @override
  void setMapController(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
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
  bool isLoading = false,
  bool isInitialized = true,
  LatLng? currentPosition,
  GoogleMapController? mapController,
}) {
  return MapState(
    isLoading: isLoading,
    isInitialized: isInitialized,
    currentPosition: currentPosition ?? const LatLng(37.579617, 126.977041),
    mapController: mapController,
  );
}

/// 로딩 상태의 Mock MapState
MapState createLoadingMapState() {
  return const MapState(
    isLoading: true,
    isInitialized: false,
    currentPosition: null,
    mapController: null,
  );
}

/// 초기화 완료된 Mock MapState
MapState createInitializedMapState() {
  return const MapState(
    isLoading: false,
    isInitialized: true,
    currentPosition: LatLng(37.579617, 126.977041),
    mapController: null,
  );
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
