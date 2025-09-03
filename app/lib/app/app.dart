import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/injection_container.dart' as di;
import 'router/app_router.dart';
import '../shared/design_system/tokens/colors.dart';
import 'services/navigation_service.dart';
import '../domains/auth/presentation/controllers/auth_controller.dart';


class TomoPlaceApp extends StatelessWidget {
  const TomoPlaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthController>(
          create: (context) => di.sl<AuthController>(),
        ),
      ],
      child: MaterialApp(
        title: 'Tomo Place',
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: DesignTokens.appColors['primary_200']!,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: DesignTokens.appColors['background'],
        ),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/splash',
      ),
    );
  }
}
