import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../controllers/map_notifier.dart';
import '../atoms/my_location_button.dart';
import '../interfaces/i_map_widget.dart';
import '../molecules/map_search_bar.dart';
import 'map_widget.dart';

/// 통합된 Map Widget 구현체
/// 
/// Map 도메인의 모든 UI 컴포넌트(Map, SearchBar, MyLocationButton)를 포함하는
/// 통합 Widget입니다. IMapWidget 인터페이스를 구현하여 Home 도메인과의
/// 의존성을 추상화합니다.
class IntegratedMapWidget extends ConsumerStatefulWidget implements IMapWidget {
  const IntegratedMapWidget({super.key});

  @override
  ConsumerState<IntegratedMapWidget> createState() => _IntegratedMapWidgetState();

  @override
  void setOnInitialized(VoidCallback? onInitialized) {
    // State에서 관리하므로 여기서는 빈 구현
  }

  @override
  void setOnMoveToCurrentLocation(VoidCallback? onMoveToCurrentLocation) {
    // State에서 관리하므로 여기서는 빈 구현
  }

  @override
  bool get isLoading {
    // State에서 관리하므로 여기서는 빈 구현
    return false;
  }

  @override
  bool get isInitialized {
    // State에서 관리하므로 여기서는 빈 구현
    return false;
  }
}

class _IntegratedMapWidgetState extends ConsumerState<IntegratedMapWidget> {
  VoidCallback? _onInitialized;
  VoidCallback? _onMoveToCurrentLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapNotifierProvider.notifier).initializeMap();
      _onInitialized?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MapWidget(),
        SafeArea(
          child: Padding(
            padding: ResponsiveSizing.getResponsivePadding(
              context,
              top: 16,
            ),
            child: const MapSearchBar(),
          ),
        ),
        Positioned(
          right: ResponsiveSizing.getValueByDevice(
            context,
            mobile: 36.0,
            tablet: 48.0,
          ),
          bottom: ResponsiveSizing.getValueByDevice(
            context,
            mobile: 36.0,
            tablet: 48.0,
          ),
          child: const MyLocationButton(),
        ),
      ],
    );
  }

  void setOnInitialized(VoidCallback? onInitialized) {
    _onInitialized = onInitialized;
  }

  void setOnMoveToCurrentLocation(VoidCallback? onMoveToCurrentLocation) {
    _onMoveToCurrentLocation = onMoveToCurrentLocation;
  }

  bool get isLoading {
    final mapState = ref.read(mapNotifierProvider);
    return mapState.isLoading;
  }

  bool get isInitialized {
    final mapState = ref.read(mapNotifierProvider);
    return mapState.currentPosition != null;
  }
}
