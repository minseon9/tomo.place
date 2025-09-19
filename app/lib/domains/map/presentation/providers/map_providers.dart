import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/location_repository.dart';
import '../../core/services/map_controller_service.dart';
import '../../core/usecases/get_current_location_usecase.dart';
import '../../core/usecases/move_to_location_usecase.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/services/google_location_service.dart';
import '../../data/services/map_controller_service_impl.dart';
import '../../data/map/map_renderer.dart';
import '../../data/map/google_map_renderer.dart';
import '../controllers/map_notifier.dart';

// Service Providers
final locationServiceProvider = Provider<LocationService>((ref) {
  return GoogleLocationService();
});

final mapControllerServiceProvider = Provider<MapControllerService>((ref) {
  return MapControllerServiceImpl();
});

// Repository Providers
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(ref.read(locationServiceProvider));
});

// UseCase Providers
final getCurrentLocationUseCaseProvider = Provider<GetCurrentLocationUseCase>((ref) {
  return GetCurrentLocationUseCase(ref.read(locationRepositoryProvider));
});

final moveToLocationUseCaseProvider = Provider<MoveToLocationUseCase>((ref) {
  return MoveToLocationUseCase(ref.read(mapControllerServiceProvider));
});

// Map Renderer Provider
final mapRendererProvider = Provider<MapRenderer>((ref) {
  return GoogleMapRenderer();
});

// MapNotifier Provider
final mapNotifierProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(ref);
});
