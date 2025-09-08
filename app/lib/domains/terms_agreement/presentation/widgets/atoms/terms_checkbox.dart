import 'package:flutter/material.dart';
import '../../../../../shared/ui/design_system/tokens/radius.dart';

/// 약관 동의용 체크박스 컴포넌트
/// 
/// 기본적으로 동의된 상태이며, 비활성화되어 있어 사용자가 직접 체크할 수 없습니다.
/// 이는 약관이 이미 동의된 상태임을 시각적으로 표현하기 위함입니다.
class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.isChecked,
    this.isEnabled = true,
    this.onChanged,
  });

  final bool isChecked;
  final bool isEnabled;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Checkbox(
        value: isChecked,
        onChanged: isEnabled ? onChanged : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        // 비활성화 상태 스타일링
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey[200];
          }
          return null;
        }),
        checkColor: Colors.black,
        activeColor: Colors.grey[300],
      ),
    );
  }
}
