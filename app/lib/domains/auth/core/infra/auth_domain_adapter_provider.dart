import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/ports/auth_domain_port.dart';
import '../../presentation/controllers/auth_notifier.dart';
import '../entities/authentication_result.dart';
import 'auth_domain_adapter.dart';

final authDomainAdapterProvider = Provider<AuthDomainPort>((ref) {
  Future<AuthenticationResult?> refreshTokenCallback() async {
    return await ref.read(authNotifierProvider.notifier).refreshToken(false);
  }

  return AuthDomainAdapter(refreshTokenCallback);
});
