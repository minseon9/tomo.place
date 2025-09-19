import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/map/map_renderer.dart';

/// 지도 상태를 나타내는 엔티티
class MapState {
  const MapState({
    this.isLoading = false,
    this.isInitialized = false,
    this.currentPosition,
    this.mapController,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isInitialized;
  final LatLng? currentPosition;
  final MapController? mapController;
  final String? errorMessage;

  /// 현재 위치가 설정되어 있는지 확인
  bool get hasCurrentPosition => currentPosition != null;

  /// 지도 컨트롤러가 설정되어 있는지 확인
  bool get hasMapController => mapController != null;

  /// 에러가 있는지 확인
  bool get hasError => errorMessage != null;


  /// 복사본 생성
  MapState copyWith({
    bool? isLoading,
    bool? isInitialized,
    LatLng? currentPosition,
    MapController? mapController,
    String? errorMessage,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      currentPosition: currentPosition ?? this.currentPosition,
      mapController: mapController ?? this.mapController,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapState &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.currentPosition == currentPosition &&
        other.mapController == mapController &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        isInitialized,
        currentPosition,
        mapController,
        errorMessage,
      );

  @override
  String toString() => 'MapState(isLoading: $isLoading, isInitialized: $isInitialized, currentPosition: $currentPosition)';
}
