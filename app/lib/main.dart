import 'package:app/shared/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AppConfig 초기화
  final container = ProviderContainer();
  final appConfig = container.read(appConfigProvider);
  await appConfig.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TomoPlaceApp(),
    ),
  );
}