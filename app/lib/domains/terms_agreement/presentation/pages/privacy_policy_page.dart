import 'package:flutter/material.dart';
import '../../../../shared/ui/design_system/tokens/typography.dart';

/// 개인정보보호방침 페이지
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('개인정보보호방침', style: AppTypography.head3),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '개인정보보호방침 내용이 여기에 표시됩니다.\n\n'
            '이 페이지는 추후 실제 개인정보보호방침 내용으로 업데이트될 예정입니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
