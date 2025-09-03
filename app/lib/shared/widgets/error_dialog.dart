import 'package:flutter/material.dart';

import '../exceptions/error_interface.dart';

class ErrorDialog extends StatelessWidget {
  final ErrorInterface error;
  final VoidCallback? onDismiss;

  const ErrorDialog({super.key, required this.error, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(error.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userMessage),
          if (error.suggestedAction != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error.suggestedAction!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required ErrorInterface error,
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) =>
          ErrorDialog(error: error, onDismiss: onDismiss),
    );
  }
}

/// 에러 스낵바를 표시하는 헬퍼 클래스
class ErrorSnackBar {
  /// 에러 스낵바를 표시하는 헬퍼 메서드
  static void show({
    required BuildContext context,
    required ErrorInterface error,
    VoidCallback? onDismiss,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.userMessage),
            if (error.suggestedAction != null) ...[
              const SizedBox(height: 4),
              Text(
                error.suggestedAction!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onDismiss?.call();
          },
        ),
      ),
    );
  }
}


