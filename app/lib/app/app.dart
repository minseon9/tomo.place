import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domains/auth/presentation/controllers/auth_notifier.dart';
import '../domains/auth/presentation/models/auth_state.dart';
import '../shared/application/navigation/navigation_actions.dart';
import '../shared/application/navigation/navigation_key.dart';
import '../shared/exception_handler/exception_notifier.dart';
import '../shared/exception_handler/models/exception_interface.dart';
import '../shared/ui/components/toast_widget.dart';
import '../shared/ui/design_system/tokens/colors.dart';
import 'pages/splash_page.dart';
import 'router/app_router.dart';

class TomoPlaceApp extends ConsumerWidget {
  const TomoPlaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    final initialRoute = ref.watch(initialRouteProvider);
    final router = ref.watch(routerProvider);

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      switch (next) {
        case AuthInitial():
          ref.read(navigationActionsProvider).navigateToSignup();
        case AuthSuccess(isNavigateHome: true):
          ref.read(navigationActionsProvider).navigateToHome();
        case AuthFailure():
          ref.read(navigationActionsProvider).navigateToSignup();
        case _:
          break;
      }
    });

    ref.listen<ExceptionInterface?>(exceptionNotifierProvider, (prev, next) {
      if (next != null) {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          AppToast.show(ctx, next.userMessage);
        }
        ref.read(exceptionNotifierProvider.notifier).clear();
      }
    });

    return MaterialApp(
      title: 'Tomo Place',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.appColors['primary_200']!,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.appColors['background'],
      ),
      onGenerateRoute: router,
      initialRoute: initialRoute,
    );
  }
}
