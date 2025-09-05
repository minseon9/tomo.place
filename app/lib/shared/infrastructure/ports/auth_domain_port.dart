import 'auth_token_dto.dart';

abstract class AuthDomainPort {
  Future<AuthTokenDto?> getValidToken();
}
