import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/map_control_repository_impl.dart';
import '../entities/map_camera.dart';

abstract class MapControlRepository<T> {
  T? _controller;
  final Completer<void> _controllerReady = Completer();

  @protected
  Future<T> get controller async {
      if (_controller == null) {
        await _controllerReady.future;
      }

      return _controller!;
  }

  void setController(T controller) {
    _controller = controller;
    if (!_controllerReady.isCompleted) {
      _controllerReady.complete();
    }
  }

  Future<void> moveCamera(MapCamera camera);

  Future<void> animateCamera(MapCamera camera, {Duration? duration});

  Future<MapCamera> getCurrentCameraPosition();

  Future<void> zoomIn();

  Future<void> zoomOut();

  Future<void> setZoom(double zoom);
}

final mapControlRepositoryProvider = Provider<MapControlRepository>((ref) {
  return MapControlRepositoryImpl();
});
