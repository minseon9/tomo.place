import 'package:equatable/equatable.dart';

/// 사용자 도메인 엔티티
/// 
/// 비즈니스 로직의 핵심이 되는 사용자 객체입니다.
/// 외부 데이터 소스에 의존하지 않는 순수한 도메인 객체입니다.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    this.provider,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final String? provider; // 'kakao', 'google', 'apple', 'email'
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// 사용자가 소셜 로그인으로 가입했는지 확인
  bool get isSocialUser => provider != null && provider != 'email';

  /// 프로필이 완성되었는지 확인
  bool get isProfileComplete => name != null && name!.isNotEmpty;

  /// 사용자 정보 업데이트를 위한 copyWith 메서드
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? provider,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        profileImageUrl,
        provider,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, provider: $provider)';
  }
}
