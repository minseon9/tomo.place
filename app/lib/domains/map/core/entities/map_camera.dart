class MapCamera {
  final double latitude;
  final double longitude;
  final double zoom;
  final double bearing;

  const MapCamera({
    required this.latitude,
    required this.longitude,
    this.zoom = 15.0,
    this.bearing = 0.0,
  });

  /// 복사본 생성
  MapCamera copyWith({
    double? latitude,
    double? longitude,
    double? zoom,
    double? bearing,
  }) {
    return MapCamera(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
      bearing: bearing ?? this.bearing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapCamera &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoom == zoom &&
        other.bearing == bearing;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, zoom, bearing);

  @override
  String toString() => 'MapPosition(lat: $latitude, lng: $longitude, zoom: $zoom, bear: $bearing)';
}
