import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

import '../../data/repositories/location_stream_repository_impl.dart';

abstract class LocationStreamRepository {
  @protected
  StreamController<MapPosition>? locationController;
  @protected
  StreamController<double>? headingController;
  @protected
  StreamController<MapPosition>? enhancedLocationController;
  @protected
  Duration interval = const Duration(seconds: 1);
  @protected
  double distanceFilter = 1.0;
  @protected
  double accuracyThreshold = 100.0;
  @protected
  MapPosition? lastPosition;
  bool _isStreaming = false;
  bool _isPaused = false;


  void updateStreamingSettings({
    Duration? interval,
    double? distanceFilter,
    double? accuracyThreshold,
  }) {
    if (interval != null) interval = interval;
    if (distanceFilter != null) distanceFilter = distanceFilter;
    if (accuracyThreshold != null) accuracyThreshold = accuracyThreshold;
  }

  bool get isStreaming => _isStreaming;

  bool get isPaused => _isPaused;

  MapPosition? get previousPosition => lastPosition;

  Stream<MapPosition> get locationStream =>
      locationController?.stream ?? const Stream.empty();

  Stream<double> get headingStream =>
      headingController?.stream ?? const Stream.empty();

  Stream<MapPosition> get enhancedLocationStream =>
      enhancedLocationController?.stream ?? const Stream.empty();


  Future<void> startStream() async {
    if (_isStreaming) return;

    locationController = StreamController<MapPosition>.broadcast();
    headingController = StreamController<double>.broadcast();
    enhancedLocationController = StreamController<MapPosition>.broadcast();
    _isStreaming = true;
    _isPaused = false;

    startLocationStreaming();
  }

  void stopStream() {
    locationController?.close();
    headingController?.close();
    enhancedLocationController?.close();
    locationController = null;
    headingController = null;
    enhancedLocationController = null;
    _isStreaming = false;
    _isPaused = false;
  }

  void pauseStream() {
    _isPaused = true;
  }

  void resumeStream() {
    _isPaused = false;
  }

  @protected
  void startLocationStreaming();
}

final locationStreamRepositoryProvider = Provider<LocationStreamRepository>((ref) {
  return LocationStreamRepositoryImpl();
});
