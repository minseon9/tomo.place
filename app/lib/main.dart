import 'package:app/shared/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize();

  runApp(const ProviderScope(child: TomoPlaceApp()));
}
