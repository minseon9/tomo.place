import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../domains/auth/core/entities/authentication_result.dart';
import '../../domains/auth/core/usecases/check_refresh_token_status_usecase.dart';
import '../../domains/auth/core/usecases/startup_refresh_token_usecase.dart';
import '../../shared/services/graceful_logout_handler.dart';
import '../services/navigation_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final checkTokenUseCase = di.sl<CheckRefreshTokenStatusUseCase>();
      final isTokenValid = await checkTokenUseCase.execute();

      if (!isTokenValid) {
        if (!mounted) return;

        NavigationService.showTokenExpiredSnackBar();

        NavigationService.navigateToSignup();
        return;
      }

      final useCase = di.sl<StartupRefreshTokenUseCase>();
      final result = await useCase.execute();

      if (!mounted) return;

      switch (result.status) {
        case AuthenticationStatus.authenticated:
          NavigationService.navigateToHome();
          break;
        case AuthenticationStatus.unauthenticated:
        case AuthenticationStatus.expired:
          NavigationService.navigateToSignup();
          break;
      }
    } catch (e) {
      if (!mounted) return;

      GracefulLogoutHandler.handleAuthError(e.toString());
      NavigationService.navigateToSignup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
