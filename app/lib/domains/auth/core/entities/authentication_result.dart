import 'package:equatable/equatable.dart';

import 'auth_token.dart';

enum AuthenticationStatus { authenticated, unauthenticated, expired }

class AuthenticationResult extends Equatable {
  final AuthenticationStatus status;
  final AuthToken? token;
  final String? message;

  const AuthenticationResult({required this.status, this.token, this.message});

  factory AuthenticationResult.authenticated(AuthToken token) {
    return AuthenticationResult(
      status: AuthenticationStatus.authenticated,
      token: token,
    );
  }

  factory AuthenticationResult.unauthenticated([String? message]) {
    return AuthenticationResult(
      status: AuthenticationStatus.unauthenticated,
      message: message ?? 'Authentication required',
    );
  }

  factory AuthenticationResult.expired([String? message]) {
    return AuthenticationResult(
      status: AuthenticationStatus.expired,
      message: message ?? 'Token expired',
    );
  }

  bool isAuthenticated() {
    return status == AuthenticationStatus.authenticated;
  }

  @override
  List<Object?> get props => [status, token, message];
}
