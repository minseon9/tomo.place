import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState({
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
    LatLng? currentPosition,
    GoogleMapController? mapController,
  }) = _MapState;
}
