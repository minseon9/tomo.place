import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/exception_handler/exception_notifier.dart';
import '../../../../shared/exception_handler/exceptions/unknown_exception.dart';
import '../../../../shared/exception_handler/models/exception_interface.dart';
import '../../core/usecases/get_current_location_usecase.dart';
import '../../core/usecases/move_to_location_usecase.dart';
import '../../core/services/map_controller_service.dart';
import '../../data/map/map_renderer.dart';
import '../models/map_state.dart';

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._ref) : super(const MapInitial());

  final Ref _ref;
  
  // 서울 경복궁 좌표 (fallback 위치)
  static const LatLng _defaultPosition = LatLng(37.579617, 126.977041);

  GetCurrentLocationUseCase get _getCurrentLocation => 
      _ref.read(getCurrentLocationUseCaseProvider);
  MoveToLocationUseCase get _moveToLocation => 
      _ref.read(moveToLocationUseCaseProvider);
  MapControllerService get _mapControllerService => _ref.read(mapControllerServiceProvider);
  ExceptionNotifier get _effects => _ref.read(exceptionNotifierProvider.notifier);

  Future<void> initializeMap() async {
    state = const MapLoading();
    try {
      final position = await _getCurrentLocation.execute();
      // 위치 정보가 준비되면 MapReady 상태로 전환
      // Controller는 Command 패턴으로 대기열에서 처리
      state = MapReady(currentPosition: position);
    } catch (e) {
      final err = _toError(e);
      state = MapError(error: err);
      _effects.report(err);
    }
  }

  Future<void> moveToCurrentLocation() async {
    if (state is! MapReady) return;
    
    final currentState = state as MapReady;
    
    try {
      // MapControllerService를 통해 지도 조작
      await _moveToLocation.execute(currentState.currentPosition);
    } catch (e) {
      final err = _toError(e);
      // Auth 패턴과 동일하게 ExceptionNotifier에 에러 전달
      _effects.report(err);
    }
  }
  
  void setMapController(MapController controller) {
    // MapControllerService에 Controller 설정
    _mapControllerService.setMapController(controller);
  }

  @override
  void dispose() {
    // MapController 생명주기 관리
    // GoogleMapController는 GoogleMap 위젯이 dispose될 때 자동으로 처리됨
    super.dispose();
  }

  ExceptionInterface _toError(dynamic e) {
    if (e is ExceptionInterface) {
      return e;
    } else {
      return UnknownException(message: e.toString());
    }
  }

}

// Provider
final mapNotifierProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(ref);
});
