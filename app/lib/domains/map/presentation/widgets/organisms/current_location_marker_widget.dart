import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/map_marker.dart';
import '../../../core/repositories/location_stream_repository.dart';
import '../../../core/usecases/get_current_location_marker_usecase.dart';
import '../../../core/usecases/move_to_location_usecase.dart';
import '../../controllers/location_permission_notifier.dart';
import '../../controllers/map_view_notifier.dart';
import '../../models/location_permission_state.dart';
import 'google/google_map_icon_registry.dart';

class CurrentLocationMarkerWidget extends ConsumerStatefulWidget {
  const CurrentLocationMarkerWidget({super.key});

  @override
  ConsumerState<CurrentLocationMarkerWidget> createState() => _CurrentLocationMarkerWidgetState();
}

class _CurrentLocationMarkerWidgetState extends ConsumerState<CurrentLocationMarkerWidget> {
  StreamSubscription? _enhancedSub;
  bool _didInitPermission = false;

  @override
  void initState() {
    super.initState();
    ref.read(mapIconRegistryProvider).preload(const {'current_with_direction'});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_didInitPermission) {
        _didInitPermission = true;
        final initPerm = ref.read(locationPermissionNotifierProvider);
        _applyPermissionAsync(initPerm);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocationPermissionState>(locationPermissionNotifierProvider, (prev, next) {
      if (prev?.hasLocationPermission != next.hasLocationPermission) {
        Future.microtask(() => _applyPermissionAsync(next));
      }
    });

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    ref.read(locationStreamRepositoryProvider).stopStream();
    super.dispose();
  }

  void _applyPermissionAsync(LocationPermissionState permissionState) async {
    final repository = ref.read(locationStreamRepositoryProvider);

    if (permissionState.hasLocationPermission) {
      await _startLocationStream(repository);
    } else {
      _stopLocationStream(repository);
    }
  }

  Future<void> _startLocationStream(LocationStreamRepository repository) async {
    if (!repository.isStreaming) {
      await repository.startStream();
    }

    _enhancedSub?.cancel();
    _enhancedSub = repository.enhancedLocationStream.listen((position) {
      final getMarker = ref.read(getCurrentLocationMarkerProvider);
      final MapMarker marker = getMarker.execute(repository.previousPosition, position);
      ref.read(mapViewControllerProvider.notifier).setCurrentLocationMarker(marker);

      final isFollowing = ref.read(mapViewControllerProvider).isFollowing;
      if (isFollowing) {
        ref.read(moveToLocationUseCaseProvider).execute(position);
      }
    });
  }

  void _stopLocationStream(LocationStreamRepository repository) async {
    _enhancedSub?.cancel();
    _enhancedSub = null;
    if (repository.isStreaming) {
      repository.stopStream();
    }
    ref.read(mapViewControllerProvider.notifier).clearMarkers();
  }
}


final currentLocationMarkerWidgetProvider = Provider<ConsumerStatefulWidget>((ref) {
  return const CurrentLocationMarkerWidget();
});


