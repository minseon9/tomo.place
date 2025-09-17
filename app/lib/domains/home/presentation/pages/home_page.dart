import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/responsive/responsive_sizing.dart';
import '../controller/map_notifier.dart';
import '../widgets/atoms/my_location_button.dart';
import '../widgets/molecules/bottom_navigation_bar.dart';
import '../widgets/molecules/map_search_bar.dart';
import '../widgets/organisms/map_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapNotifierProvider.notifier).initializeMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
      ),
      bottomNavigationBar: const BottomNavigationBar(currentIndex: null),
    );
  }
}
