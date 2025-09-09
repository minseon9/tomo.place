import 'package:flutter/material.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';
import '../../../../../shared/ui/design_system/tokens/colors.dart';

/// 약관 내용 표시 컴포넌트
/// 
/// 약관 제목과 본문을 표시하며, 본문이 길 경우 스크롤 가능합니다.
/// Figma 디자인에 따라 📌 아이콘과 함께 제목을 표시하고,
/// 본문은 구조화된 섹션으로 구성됩니다.
class TermsContent extends StatelessWidget {
  const TermsContent({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목 (📌 아이콘 + 약관명)
        Text(
          '📌 $title',
          style: AppTypography.header2.copyWith(
            color: DesignTokens.tomoBlack,
            letterSpacing: -0.48,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 본문 내용 (스크롤 가능)
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              content,
              style: AppTypography.body.copyWith(
                color: DesignTokens.tomoBlack,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
