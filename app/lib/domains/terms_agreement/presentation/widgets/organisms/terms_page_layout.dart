import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../../shared/ui/design_system/tokens/typography.dart';
import '../atoms/terms_page_agree_button.dart';
import '../molecules/terms_content.dart';

class TermsPageLayout extends StatelessWidget {
  const TermsPageLayout({
    super.key,
    required this.title,
    required this.contentMap,
    required this.onAgree,
  });

  final String title;
  final Map<String, String> contentMap;
  final VoidCallback onAgree;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상단 헤더
          Container(
            decoration: BoxDecoration(
              color: AppColors.tomoPrimary200, // #f2e5cc
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 23,
                  bottom: 10,
                  right: 20,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    '📌 $title',
                    style: AppTypography.header2.copyWith(
                      letterSpacing: 0.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 본문
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 23, right: 23),
              child: TermsContent(contentMap: contentMap),
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.only(left: 47, right: 47, bottom: 20),
            child: TermsPageAgreeButton(onPressed: onAgree),
          ),
        ],
      ),
    );
  }
}
