import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_renderer.dart';
import 'google_map_renderer.dart';

final mapRendererProvider = Provider<MapRenderer>((ref) {
  return GoogleMapRenderer();
});

