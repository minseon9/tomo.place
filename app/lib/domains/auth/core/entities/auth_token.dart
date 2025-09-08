import 'package:clock/clock.dart';

class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String tokenType;

  bool get isAccessTokenExpired {
    return clock.now().isAfter(accessTokenExpiresAt);
  }

  bool get isRefreshTokenExpired {
    return clock.now().isAfter(refreshTokenExpiresAt);
  }

  bool get isAccessTokenAboutToExpire {
    final fiveMinutesFromNow = clock.now().add(const Duration(minutes: 5));

    return fiveMinutesFromNow.isAfter(accessTokenExpiresAt);
  }

  bool get isRefreshTokenAboutToExpire {
    final fiveMinutesFromNow = clock.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(refreshTokenExpiresAt);
  }

  bool get isAccessTokenValid {
    return !isAccessTokenExpired && !isAccessTokenAboutToExpire;
  }

  bool get isRefreshTokenValid {
    return !isRefreshTokenExpired;
  }

  String get authorizationHeader => '$tokenType $accessToken';

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt'] as String,
      ),
      refreshTokenExpiresAt: DateTime.parse(
        json['refreshTokenExpiresAt'] as String,
      ),
    );
  }
}
