import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/typography.dart';

/// 로그인 화면 하단 링크 그룹 컴포넌트
/// 
/// 로그인 화면 하단의 "이메일로 로그인 | 회원 가입" 링크들을 그룹화합니다.
/// 구분선이 화면의 좌우 중앙에 위치하고, 텍스트들이 구분선 기준으로 적절한 간격을 가집니다.
class LoginBottomLinksGroup extends StatelessWidget {
  final VoidCallback? onEmailLogin;
  final VoidCallback? onSignUp;

  const LoginBottomLinksGroup({
    super.key,
    this.onEmailLogin,
    this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 너비의 10%를 간격으로 사용 (최소 20px, 최대 40px)
        final gap = (constraints.maxWidth * 0.1).clamp(20.0, 40.0);
        
        return Row(
          children: [
            // 왼쪽 영역
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onEmailLogin,
                    child: Text(
                      '이메일로 로그인',
                      style: AppTypography.caption.copyWith(
                        color: DesignTokens.tomoDarkGray,
                      ),
                    ),
                  ),
                  SizedBox(width: gap), // 구분선과의 간격
                ],
              ),
            ),
            // 중앙 구분선
            Container(
              width: 1,
              height: 15,
              color: DesignTokens.tomoDarkGray,
            ),
            // 오른쪽 영역
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: gap), // 구분선과의 간격
                  GestureDetector(
                    onTap: onSignUp,
                    child: Text(
                      '회원 가입',
                      style: AppTypography.caption.copyWith(
                        color: DesignTokens.tomoDarkGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
