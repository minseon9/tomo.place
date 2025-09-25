import 'package:flutter/material.dart';

import '../../../../../shared/application/routes/routes.dart';
import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/radius.dart';
import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../../../shared/ui/responsive/responsive_spacing.dart';
import '../atoms/terms_agree_button.dart';
import '../molecules/terms_agreement_item.dart';

enum TermsAgreementResult {
  agreed,
  dismissed,
}

class TermsAgreementModal extends StatelessWidget {
  const TermsAgreementModal({
    super.key,
    required this.onResult,
  });

  final void Function(TermsAgreementResult result) onResult;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => onResult(TermsAgreementResult.dismissed),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            color: Colors.transparent,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dy > 0) {
                onResult(TermsAgreementResult.dismissed);
              }
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: ResponsiveSizing.getResponsiveHeight(
                context,
                0.4,
                minHeight: 350,
                maxHeight: 600,
              ),
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

                  // 모달 내용
                  Expanded(
                    child: Padding(
                      padding: ResponsiveSizing.getResponsiveEdge(
                        context,
                        left: 29,
                        top: 21,
                        right: 29,
                      ),
                      child: Column(
                        children: [
                          TermsAgreementItem(
                            title: '이용 약관 동의',
                            isChecked: true,
                            hasExpandIcon: true,
                            onExpandTap: () => _navigateToTerms(context),
                          ),
                          SizedBox(
                            height: ResponsiveSpacing.getResponsive(context, 7),
                          ),
                          TermsAgreementItem(
                            title: '개인정보 보호 방침 동의',
                            isChecked: true,
                            hasExpandIcon: true,
                            onExpandTap: () => _navigateToPrivacy(context),
                          ),
                          SizedBox(
                            height: ResponsiveSpacing.getResponsive(context, 7),
                          ),
                          TermsAgreementItem(
                            title: '위치정보 수집·이용 및 제3자 제공 동의',
                            isChecked: true,
                            hasExpandIcon: true,
                            onExpandTap: () => _navigateToLocation(context),
                          ),

                          SizedBox(
                            height: ResponsiveSpacing.getResponsive(context, 7),
                          ),
                          TermsAgreementItem(
                            title: '만 14세 이상입니다',
                            isChecked: true,
                            hasExpandIcon: false,
                          ),
                          SizedBox(
                            height: ResponsiveSpacing.getResponsive(context, 7),
                          ),
                          // 약관 리스트와 버튼 사이 간격
                          TermsAgreeButton(
                            onPressed: () => onResult(TermsAgreementResult.agreed),
                          ),
                        ],
                      ),
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

  void _navigateToTerms(BuildContext context) {
    Navigator.pushNamed(context, Routes.termsOfService);
  }

  void _navigateToPrivacy(BuildContext context) {
    Navigator.pushNamed(context, Routes.privacyPolicy);
  }

  void _navigateToLocation(BuildContext context) {
    Navigator.pushNamed(context, Routes.locationTerms);
  }
}
