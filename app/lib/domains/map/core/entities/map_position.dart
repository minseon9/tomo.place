import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 지도 위치를 나타내는 엔티티
class MapPosition {
  const MapPosition({
    required this.latitude,
    required this.longitude,
    this.zoom = 16.0,
  });

  final double latitude;
  final double longitude;
  final double zoom;

  /// LatLng로 변환
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// CameraPosition으로 변환
  CameraPosition toCameraPosition() => CameraPosition(
        target: toLatLng(),
        zoom: zoom,
      );

  /// 복사본 생성
  MapPosition copyWith({
    double? latitude,
    double? longitude,
    double? zoom,
  }) {
    return MapPosition(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapPosition &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoom == zoom;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, zoom);

  @override
  String toString() => 'MapPosition(lat: $latitude, lng: $longitude, zoom: $zoom)';
}
