// 도메인 상수: 소셜 로그인 제공자 종류
enum SocialProvider {
  kakao('KAKAO'),
  apple('APPLE'), 
  google('GOOGLE');

  const SocialProvider(this.code);
  final String code;
}
