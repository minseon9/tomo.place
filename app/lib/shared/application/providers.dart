import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation/navigation_providers.dart';

// Export types for external use

// Navigation Providers
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

final navigationActionsProvider = Provider<NavigationActions>(
  (ref) => NavigationActions(ref.watch(navigatorKeyProvider)),
);
