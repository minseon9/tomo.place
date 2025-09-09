import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/radius.dart';
import '../atoms/terms_agree_button.dart';
import '../molecules/terms_agreement_item.dart';

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
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 모달 외부 배경 (터치 시 닫기)
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
          ),
        ),
        // 모달 컨텐츠
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dy > 0) {
                onDismiss?.call();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 359,
              decoration: BoxDecoration(
                color: AppColors.tomoPrimary100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Grabber
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.neutralColors['light_gray'],
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                  ),

                  Padding(
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
                        const SizedBox(height: 12), // 약관 리스트와 버튼 사이 간격
                        TermsAgreeButton(onPressed: onAgreeAll ?? () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
