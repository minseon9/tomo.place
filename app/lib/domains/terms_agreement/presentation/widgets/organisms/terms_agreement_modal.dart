import 'package:flutter/material.dart';
import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/radius.dart';
import '../molecules/terms_agreement_item.dart';
import '../atoms/terms_agree_button.dart';

/// 약관 동의 모달 컴포넌트
/// 
/// 4개의 약관 동의 항목과 모두 동의 버튼을 포함하는 모달입니다.
/// 외부 터치나 드래그로 모달을 닫을 수 있으며, 예외 처리 없이 단순히 닫힙니다.
class TermsAgreementModal extends StatelessWidget {
  const TermsAgreementModal({
    super.key,
    this.onAgreeAll,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onLocationTap,
    this.onDismiss,
  });

  final VoidCallback? onAgreeAll;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onDismiss; // 모달 닫기 콜백

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss, // 외부 터치 시 모달 닫기
      child: Container(
        width: 394,
        height: 359,
        decoration: BoxDecoration(
          color: DesignTokens.tomoPrimary100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {}, // 모달 내부 터치 시 이벤트 전파 방지
          child: Column(
            children: [
              // 상단 그랩바 (드래그 가능)
              GestureDetector(
                onPanUpdate: (details) {
                  // 아래로 드래그 시 모달 닫기
                  if (details.delta.dy > 0) {
                    onDismiss?.call();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: DesignTokens.neutralColors['light_gray'],
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                ),
              ),
              
              // 약관 동의 항목들
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(29, 21, 29, 0),
                  child: Column(
                    children: [
                      TermsAgreementItem(
                        title: '이용 약관 동의',
                        isChecked: true,
                        hasExpandIcon: true,
                        onExpandTap: onTermsTap,
                      ),
                      const SizedBox(height: 7),
                      TermsAgreementItem(
                        title: '개인정보 보호 방침 동의',
                        isChecked: true,
                        hasExpandIcon: true,
                        onExpandTap: onPrivacyTap,
                      ),
                      const SizedBox(height: 7),
                      TermsAgreementItem(
                        title: '위치정보 수집·이용 및 제3자 제공 동의',
                        isChecked: true,
                        hasExpandIcon: true,
                        onExpandTap: onLocationTap,
                      ),
                      const SizedBox(height: 7),
                      TermsAgreementItem(
                        title: '만 14세 이상입니다',
                        isChecked: true,
                        hasExpandIcon: false,
                      ),
                    ],
                  ),
                ),
              ),
              
              // 하단 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(47, 0, 47, 0),
                child: TermsAgreeButton(onPressed: onAgreeAll ?? () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
