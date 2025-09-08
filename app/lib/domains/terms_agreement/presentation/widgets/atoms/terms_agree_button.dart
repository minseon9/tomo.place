import 'package:flutter/material.dart';
import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';
import '../../../../../shared/ui/design_system/tokens/radius.dart';

/// 약관 동의 완료 버튼 컴포넌트
/// 
/// "모두 동의합니다 !" 텍스트가 포함된 버튼으로,
/// 클릭 시 모든 약관에 동의한 것으로 처리됩니다.
class TermsAgreeButton extends StatelessWidget {
  const TermsAgreeButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 45,
      decoration: BoxDecoration(
        color: DesignTokens.tomoPrimary300,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Center(
            child: Text(
              '모두 동의합니다 !',
              style: AppTypography.button.copyWith(
                color: DesignTokens.socialButtons['kakao_text'],
                letterSpacing: -0.28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
