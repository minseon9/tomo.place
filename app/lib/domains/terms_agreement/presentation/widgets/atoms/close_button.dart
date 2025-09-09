import 'package:flutter/material.dart';

class TermsCloseButton extends StatelessWidget {
  const TermsCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.close, size: 24, color: Colors.black),
      ),
    );
  }
}
