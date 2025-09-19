import 'package:flutter/material.dart';
import 'package:tomo_place/shared/application/routes/routes.dart';

import '../pages/home_page.dart';

class HomeRoutes {
  static Map<String, WidgetBuilder> get builders => {
    Routes.home: (context) => const HomePage(),
  };
}
