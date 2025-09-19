import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/exception_handler/models/exception_interface.dart';

/// Map 상태를 나타내는 추상 클래스 (Auth 패턴 적용)
abstract class MapState extends Equatable {
  const MapState();
}

/// Map 초기 상태
class MapInitial extends MapState {
  const MapInitial();
  
  @override
  List<Object?> get props => [];
}

/// Map 로딩 상태
class MapLoading extends MapState {
  const MapLoading();
  
  @override
  List<Object?> get props => [];
}

/// Map 준비 완료 상태
class MapReady extends MapState {
  final LatLng currentPosition;
  
  const MapReady({required this.currentPosition});
  
  @override
  List<Object?> get props => [currentPosition];
}

/// Map 에러 상태
class MapError extends MapState {
  final ExceptionInterface error;
  
  const MapError({required this.error});
  
  @override
  List<Object?> get props => [error];
}
