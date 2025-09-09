import 'package:flutter/material.dart';
import '../widgets/organisms/terms_page_layout.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String _privacyContent = '''
수집·이용 목적
• 회원 식별 및 본인 확인 (OIDC 로그인: 이메일, 프로필 정보)
• 서비스 제공 및 맞춤형 기능 제공
• 고객 문의 응대 및 분쟁 해결

수집 항목
• 필수: 이메일, 프로필 정보(닉네임, 프로필 사진 등), 위치정보(서비스 이용 시 수집)
• 선택: 마케팅 정보 수신 여부(푸시 알림, 이메일 등)

보유·이용 기간
• 회원 탈퇴 시, 파기를 원칙
• 단, 법령에 따라 일정 기간 보관이 필요한 경우 예외
• 분쟁 해결 및 법적 대응을 위해 탈퇴 후 n개월간 보관 가능하며 이후 완전 삭제

동의 거부 권리 및 불이익
• 이용자는 개인정보 제공 동의를 거부할 권리가 있습니다.
• 다만, 필수 항목 동의 거부 시 서비스 가입 및 이용이 제한될 수 있습니다.
''';

  @override
  Widget build(BuildContext context) {
    return TermsPageLayout(
      title: '개인 정보 보호 방침 동의',
      content: _privacyContent,
      onClose: () => Navigator.of(context).pop(),
      onAgree: () => Navigator.of(context).pop(),
    );
  }
}
