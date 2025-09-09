import 'package:flutter/material.dart';

import '../../../../../shared/ui/design_system/tokens/colors.dart';
import '../atoms/close_button.dart';
import '../atoms/terms_agree_button.dart';
import '../molecules/terms_content.dart';

class TermsPageLayout extends StatelessWidget {
  const TermsPageLayout({
    super.key,
    required this.title,
    required this.content,
    required this.onClose,
    required this.onAgree,
  });

  final String title;
  final String content;
  final VoidCallback onClose;
  final VoidCallback onAgree;

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(
                color: DesignTokens.tomoPrimary200, // #f2e5cc
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // 닫기 버튼 (우상단)
                    Positioned(
                      top: 19,
                      right: 16,
                      child: TermsCloseButton(onPressed: onClose),
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
            child: TermsContent(title: title, content: content),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 124,
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.tomoPrimary200, // #f2e5cc
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              child: SafeArea(
                child: Center(child: TermsAgreeButton(onPressed: onAgree)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
