class MapPosition {
  const MapPosition({
    required this.latitude,
    required this.longitude,
    required this.heading,
    this.zoom = 16.0,
  });

  final double latitude;
  final double longitude;
  final double heading;
  final double zoom;

  MapPosition copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? zoom,
  }) {
    return MapPosition(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
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
  int get hashCode => Object.hash(latitude, longitude, heading, zoom);

  @override
  String toString() => 'MapPosition(lat: $latitude, lng: $longitude, heading: $heading, zoom: $zoom)';
}
