import 'package:equatable/equatable.dart';

// FIXME: token 별 expiration
class AuthToken extends Equatable {
  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  /// 토큰이 만료되었는지 확인
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// 토큰이 곧 만료될지 확인 (5분 전)
  bool get isAboutToExpire {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// 토큰이 유효한지 확인 (5분 여유 시간 포함)
  bool get isValid {
    if (isExpired) return false;

    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isBefore(expiresAt);
  }

  /// 토큰 상태를 문자열로 표현
  String get status {
    if (isExpired) return 'expired';
    if (isAboutToExpire) return 'expiring_soon';
    return 'valid';
  }

  /// Authorization 헤더에 사용할 형식
  String get authorizationHeader => '$tokenType $accessToken';

  /// JSON에서 AuthToken 객체 생성
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }



  /// AuthToken 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': tokenType,
    };
  }

  /// 토큰 업데이트를 위한 copyWith 메서드
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  List<Object> get props => [accessToken, refreshToken, expiresAt, tokenType];

  @override
  String toString() {
    return 'AuthToken(type: $tokenType, expiresAt: $expiresAt, isExpired: $isExpired)';
  }
}
