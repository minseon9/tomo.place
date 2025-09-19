import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class MapPageInterface extends ConsumerStatefulWidget {
  const MapPageInterface({super.key});

  void setOnInitialized(VoidCallback? onInitialized);

  void setOnMoveToCurrentLocation(VoidCallback? onMoveToCurrentLocation);
}
