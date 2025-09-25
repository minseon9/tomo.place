class MapMarker {
  final String id;
  final double lat;
  final double lng;
  final double rotation;
  final double anchorX;
  final double anchorY;
  final String iconKey;
  final String? title;
  final String? snippet;

  const MapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    this.rotation = 0,
    this.anchorX = 0.5,
    this.anchorY = 0.5,
    this.iconKey = 'default',
    this.title,
    this.snippet,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapMarker &&
        other.id == id &&
        other.lat == lat &&
        other.lng == lng &&
        other.rotation == rotation &&
        other.anchorX == anchorX &&
        other.anchorY == anchorY &&
        other.iconKey == iconKey &&
        other.title == title &&
        other.snippet == snippet;
  }

  @override
  int get hashCode => Object.hash(
        id,
        lat,
        lng,
        rotation,
        anchorX,
        anchorY,
        iconKey,
        title,
        snippet,
      );
}


