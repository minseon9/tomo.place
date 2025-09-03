import '../../core/entities/auth_token.dart';
import '../models/refresh_token_api_response.dart';
import '../models/signup_api_response.dart';

class AuthTokenMapper {
  static AuthToken fromSignupResponse(SignupApiResponse response) {
    return AuthToken(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresAt: response.accessTokenExpiresAt,
      tokenType: 'Bearer',
    );
  }
  
  static AuthToken fromRefreshTokenResponse(RefreshTokenApiResponse response) {
    return AuthToken(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresAt: response.accessTokenExpiresAt,
      tokenType: 'Bearer',
    );
  }
}
