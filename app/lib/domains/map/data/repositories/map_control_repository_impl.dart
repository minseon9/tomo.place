import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/entities/map_camera.dart';
import '../../core/repositories/map_control_repository.dart';

class MapControlRepositoryImpl<GoogleMapController> extends MapControlRepository {
  MapControlRepositoryImpl();


  @override
  Future<void> moveCamera(MapCamera camera) async {
    await (await controller).moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(camera.latitude, camera.longitude),
          zoom: camera.zoom,
          bearing: camera.bearing,
        ),
      ),
    );
  }

  @override
  Future<void> animateCamera(MapCamera camera, {Duration? duration}) async {
    await (await controller).animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(camera.latitude, camera.longitude),
          zoom: camera.zoom,
          bearing: camera.bearing,
        ),
      ),
    );
  }

  @override
  Future<MapCamera> getCurrentCameraPosition() async {
    final position = await (await controller).getCameraPosition();
    return MapCamera(
      latitude: position.target.latitude,
      longitude: position.target.longitude,
      zoom: position.zoom,
      bearing: position.bearing,
    );
  }

  @override
  Future<void> zoomIn() async {
    await (await controller).animateCamera(CameraUpdate.zoomIn());
  }

  @override
  Future<void> zoomOut() async {
    await (await controller).animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Future<void> setZoom(double zoom) async {
    await (await controller).animateCamera(CameraUpdate.zoomTo(zoom));
  }
}
