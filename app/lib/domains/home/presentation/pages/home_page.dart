import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../map/presentation/pages/map_page.dart';
import '../widgets/molecules/bottom_navigation_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final mapPage = ref.watch(mapPageProvider);
    
    return Scaffold(
      body: mapPage,
      bottomNavigationBar: const BottomNavigationBar(currentIndex: null),
    );
  }
}
