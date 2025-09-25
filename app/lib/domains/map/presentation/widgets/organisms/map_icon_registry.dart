abstract class MapIcon {
  const MapIcon();
}

abstract class MapIconRegistry {
  Future<void> preload(Set<String> iconKeys, {double? size});
  
  MapIcon? get(String key);
}
