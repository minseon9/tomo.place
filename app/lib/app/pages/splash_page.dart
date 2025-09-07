import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domains/auth/presentation/controllers/auth_notifier.dart';


class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthenticationStatus();
      }
    });
  }

  Future<void> _checkAuthenticationStatus() async {
    if (!mounted) return;
    
    final container = ProviderScope.containerOf(context);
    if (container.exists(authNotifierProvider)) {
      await ref.read(authNotifierProvider.notifier).refreshToken(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

final initialRouteProvider = Provider<String>((ref) => '/splash');
