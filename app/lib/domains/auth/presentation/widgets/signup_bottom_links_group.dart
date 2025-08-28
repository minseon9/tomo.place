import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/typography.dart';

/// 회원가입 화면 하단 링크 그룹 컴포넌트
/// 
/// 회원가입 화면 하단의 "이미 계정이 있어요" 링크를 표시합니다.
class SignupBottomLinksGroup extends StatelessWidget {
  final VoidCallback? onEmailLogin;

  const SignupBottomLinksGroup({
    super.key,
    this.onEmailLogin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEmailLogin,
      child: Text(
        '이미 계정이 있어요',
        style: AppTypography.caption.copyWith(
          color: DesignTokens.tomoDarkGray,
        ),
      ),
    );
  }
}
