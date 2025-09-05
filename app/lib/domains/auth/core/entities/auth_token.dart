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
    return DateTime.now().isAfter(accessTokenExpiresAt);
  }

  bool get isRefreshTokenExpired {
    return DateTime.now().isAfter(refreshTokenExpiresAt);
  }

  bool get isAccessTokenAboutToExpire {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));

    return fiveMinutesFromNow.isAfter(accessTokenExpiresAt);
  }

  bool get isRefreshTokenAboutToExpire {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
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
