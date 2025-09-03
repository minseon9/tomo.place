import 'package:flutter/material.dart';

import 'app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 의존성 주입 초기화
  await di.initializeDependencies();
  
  runApp(const ProviderScope(child: TomoPlaceApp()));
}