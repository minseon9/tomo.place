import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';
import 'package:tomo_place/shared/infrastructure/ports/auth_domain_port.dart';

import '../../../../shared/infrastructure/ports/auth_token_dto.dart';

class AuthDomainAdapter implements AuthDomainPort {
  final Future<AuthenticationResult?> Function() _refreshTokenCallback;

  AuthDomainAdapter(this._refreshTokenCallback);

  @override
  Future<AuthTokenDto?> getValidToken() async {
    final result = await _refreshTokenCallback();

    if (result == null || !result.isAuthenticated() || result.token == null) {
      return null;
    }

    return AuthTokenDto(
      accessToken: result.token!.accessToken,
      accessTokenExpiresAt: result.token!.accessTokenExpiresAt,
      tokenType: result.token!.tokenType,
    );
  }
}
