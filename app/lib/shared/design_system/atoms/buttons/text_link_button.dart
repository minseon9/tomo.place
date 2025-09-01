import 'package:flutter/material.dart';

/// 텍스트 링크 버튼 컴포넌트
/// 
/// 하단의 텍스트 링크들을 위한 클릭 가능한 텍스트 컴포넌트입니다.
/// 피그마 디자인: Apple SD Gothic Neo, 12px, #8c8c8c, 15px 높이
class TextLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDivider;

  const TextLinkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDivider) {
      return Text(
        text,
        style: const TextStyle(
          fontFamily: 'Apple SD Gothic Neo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8C8C8C),
          height: 1.0,
        ),
      );
    }
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: 15, // 피그마: 15px 높이
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Apple SD Gothic Neo',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8C8C8C), // 피그마: #8c8c8c
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
