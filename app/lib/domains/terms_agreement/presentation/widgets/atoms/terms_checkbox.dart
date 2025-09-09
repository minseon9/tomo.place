import 'package:flutter/material.dart';
import '../../../../../shared/ui/design_system/tokens/radius.dart';

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
