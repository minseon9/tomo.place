import 'package:flutter/material.dart';

class FakeTermsDataGenerator {
  FakeTermsDataGenerator._();

  static Widget createFakeCheckbox({
    bool isChecked = true,
    bool isEnabled = false,
    ValueChanged<bool?>? onChanged,
  }) {
    return Checkbox(value: isChecked, onChanged: isEnabled ? onChanged : null);
  }

  static Widget createFakeExpandIcon({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.chevron_right),
    );
  }

  static Widget createFakeAgreeButton({VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      child: const Text('모두 동의합니다 !'),
    );
  }

  static Widget createFakeTermsItem({
    String title = '이용 약관 동의',
    bool isChecked = true,
    bool hasExpandIcon = true,
    VoidCallback? onExpandTap,
  }) {
    return Row(
      children: [
        createFakeCheckbox(isChecked: isChecked),
        Expanded(child: Text(title)),
        if (hasExpandIcon) createFakeExpandIcon(onTap: onExpandTap),
      ],
    );
  }

  static List<Widget> createFakeTermsList() {
    return [
      createFakeTermsItem(
        title: '이용 약관 동의',
        isChecked: true,
        hasExpandIcon: true,
      ),
      createFakeTermsItem(
        title: '개인정보 보호 방침 동의',
        isChecked: true,
        hasExpandIcon: true,
      ),
      createFakeTermsItem(
        title: '위치정보 수집·이용 및 제3자 제공 동의',
        isChecked: true,
        hasExpandIcon: true,
      ),
      createFakeTermsItem(
        title: '만 14세 이상입니다',
        isChecked: true,
        hasExpandIcon: false,
      ),
    ];
  }

  static Widget createFakeModal({
    VoidCallback? onAgreeAll,
    VoidCallback? onTermsTap,
    VoidCallback? onPrivacyTap,
    VoidCallback? onLocationTap,
    VoidCallback? onDismiss,
  }) {
    return Column(
      children: [
        ...createFakeTermsList(),
        createFakeAgreeButton(onPressed: onAgreeAll),
      ],
    );
  }

  static VoidCallback createFakeCallback() {
    return () {};
  }

  static ValueChanged<bool?> createFakeValueChangedCallback() {
    return (value) {};
  }

  static Widget createFakeTermsCloseButton({VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed ?? () {},
      icon: const Icon(Icons.close, size: 24, color: Colors.black),
      padding: EdgeInsets.zero,
    );
  }

  static Widget createFakeTermsContent({
    String title = '📌 이용 약관 동의',
    String content = '약관 내용이 여기에 표시됩니다.',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 24),
        Expanded(child: SingleChildScrollView(child: Text(content))),
      ],
    );
  }

  static Widget createFakeTermsPageLayout({
    String title = '이용 약관 동의',
    String content = '약관 내용',
    VoidCallback? onClose,
    VoidCallback? onAgree,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 88,
            child: Container(
              color: const Color(0xFFF2E5CC),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 19,
                      right: 16,
                      child: createFakeTermsCloseButton(onPressed: onClose),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 88,
            left: 23,
            right: 23,
            bottom: 124,
            child: createFakeTermsContent(title: title, content: content),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 124,
            child: Container(
              color: const Color(0xFFF2E5CC),
              child: SafeArea(
                child: Center(child: createFakeAgreeButton(onPressed: onAgree)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String createFakeTermsContentText({String type = 'terms'}) {
    switch (type) {
      case 'terms':
        return '''
제1조 (목적)
본 약관은 [서비스명]이 제공하는 서비스의 이용 조건 및 절차를 규정함을 목적으로 합니다.

제2조 (회원의 의무)
1. 회원은 관계 법령 및 본 약관의 규정을 준수하여야 합니다.
2. 회원은 타인의 권리를 침해해서는 안 됩니다.
''';
      case 'privacy':
        return '''
수집·이용 목적
• 회원 식별 및 본인 확인
• 서비스 제공 및 맞춤형 기능 제공

수집 항목
• 필수: 이메일, 프로필 정보
• 선택: 마케팅 정보 수신 여부
''';
      case 'location':
        return '''
수집·이용 목적
• 사용자 위치 기반 서비스 제공
• 타인과 위치 공유 기능 제공

수집 항목
• 단말기 위치정보(GPS, 기지국, Wi-Fi 등)
''';
      default:
        return '기본 약관 내용입니다.';
    }
  }

  static String createFakeTermsTitle({String type = 'terms'}) {
    switch (type) {
      case 'terms':
        return '이용 약관 동의';
      case 'privacy':
        return '개인 정보 보호 방침 동의';
      case 'location':
        return '위치정보 수집·이용 및 제3자 제공 동의';
      default:
        return '약관 동의';
    }
  }
}
