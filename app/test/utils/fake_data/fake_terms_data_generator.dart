import 'package:flutter/material.dart';

/// 약관 관련 가짜 데이터 생성기
class FakeTermsDataGenerator {
  FakeTermsDataGenerator._();

  /// 가짜 체크박스 생성
  static Widget createFakeCheckbox({
    bool isChecked = true,
    bool isEnabled = false,
    ValueChanged<bool?>? onChanged,
  }) {
    return Checkbox(
      value: isChecked,
      onChanged: isEnabled ? onChanged : null,
    );
  }

  /// 가짜 확장 아이콘 생성
  static Widget createFakeExpandIcon({
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.chevron_right),
    );
  }

  /// 가짜 동의 버튼 생성
  static Widget createFakeAgreeButton({
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      child: const Text('모두 동의합니다 !'),
    );
  }

  /// 가짜 약관 항목 생성
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

  /// 가짜 약관 목록 생성
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

  /// 가짜 모달 생성
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

  /// 가짜 콜백 생성
  static VoidCallback createFakeCallback() {
    return () {};
  }

  /// 가짜 ValueChanged 콜백 생성
  static ValueChanged<bool?> createFakeValueChangedCallback() {
    return (value) {};
  }
}
