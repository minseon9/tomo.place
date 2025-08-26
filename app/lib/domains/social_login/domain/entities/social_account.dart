import 'package:equatable/equatable.dart';

/// 소셜 계정 도메인 엔티티
/// 
/// 소셜 로그인으로부터 받아온 계정 정보를 나타내는 도메인 객체입니다.
/// 각 소셜 플랫폼의 특성을 추상화한 공통 인터페이스를 제공합니다.
class SocialAccount extends Equatable {
  const SocialAccount({
    required this.provider,
    required this.providerUserId,
    required this.accessToken,
    this.email,
    this.name,
    this.profileImageUrl,
    this.refreshToken,
    this.expiresAt,
    this.additionalData = const {},
  });

  /// 소셜 로그인 제공자 ('kakao', 'google', 'apple')
  final String provider;
  
  /// 해당 제공자에서의 사용자 고유 ID
  final String providerUserId;
  
  /// 접근 토큰
  final String accessToken;
  
  /// 이메일 (제공자에 따라 null일 수 있음)
  final String? email;
  
  /// 이름/닉네임 (제공자에 따라 null일 수 있음)
  final String? name;
  
  /// 프로필 이미지 URL
  final String? profileImageUrl;
  
  /// 갱신 토큰 (제공자에 따라 null일 수 있음)
  final String? refreshToken;
  
  /// 토큰 만료 시간
  final DateTime? expiresAt;
  
  /// 제공자별 추가 데이터
  final Map<String, dynamic> additionalData;

  /// 이메일이 제공되었는지 확인
  bool get hasEmail => email != null && email!.isNotEmpty;

  /// 이름이 제공되었는지 확인
  bool get hasName => name != null && name!.isNotEmpty;

  /// 토큰이 만료되었는지 확인
  bool get isTokenExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 제공자별 특별한 식별자 반환
  String get uniqueIdentifier => '${provider}_$providerUserId';

  SocialAccount copyWith({
    String? provider,
    String? providerUserId,
    String? accessToken,
    String? email,
    String? name,
    String? profileImageUrl,
    String? refreshToken,
    DateTime? expiresAt,
    Map<String, dynamic>? additionalData,
  }) {
    return SocialAccount(
      provider: provider ?? this.provider,
      providerUserId: providerUserId ?? this.providerUserId,
      accessToken: accessToken ?? this.accessToken,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  List<Object?> get props => [
        provider,
        providerUserId,
        accessToken,
        email,
        name,
        profileImageUrl,
        refreshToken,
        expiresAt,
        additionalData,
      ];

  @override
  String toString() {
    return 'SocialAccount(provider: $provider, email: $email, name: $name)';
  }
}
