import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../map_icon_registry.dart';

class GoogleMapIcon extends MapIcon {
  final BitmapDescriptor bitmap;
  const GoogleMapIcon(this.bitmap);
}

class GoogleMapIconRegistry implements MapIconRegistry {
  final Map<String, GoogleMapIcon> _cache = {};
  final double defaultSize;

  GoogleMapIconRegistry({this.defaultSize = 56});

  @override
  Future<void> preload(Set<String> iconKeys, {double? size}) async {
    for (final key in iconKeys) {
      if (_cache.containsKey(key)) continue;
      
      final path = _assetForIconKey(key);
      final icon = await _fromSvgAsset(assetPath: path, size: (size ?? defaultSize));
      _cache[key] = GoogleMapIcon(icon);
    }
  }

  @override
  MapIcon? get(String key) => _cache[key];

  String _assetForIconKey(String iconKey) {
    switch (iconKey) {
      case 'current_with_direction':
        return 'assets/icons/current_location_marker.svg';
      default:
        return 'assets/icons/current_location_marker.svg';
    }
  }

  Future<BitmapDescriptor> _fromSvgAsset({
    required String assetPath,
    double size = 48,
  }) async {
    final String svgString = await rootBundle.loadString(assetPath);
    final svg.PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    final ui.Image image = await pictureInfo.picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}

final mapIconRegistryProvider = Provider<MapIconRegistry>((ref) {
  return GoogleMapIconRegistry();
});
