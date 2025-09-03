import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../domains/auth/core/entities/authentication_result.dart';
import '../../domains/auth/core/usecases/startup_refresh_token_usecase.dart';

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
    final useCase = di.sl<StartupRefreshTokenUseCase>();
    final result = await useCase.execute();
    if (!mounted) return;
    switch (result.status) {
      case AuthenticationStatus.authenticated:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case AuthenticationStatus.unauthenticated:
      case AuthenticationStatus.expired:
        Navigator.of(context).pushReplacementNamed('/signup');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
