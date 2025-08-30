import 'package:flutter/material.dart';

import '../exceptions/network_exception.dart';
import '../exceptions/oauth_exception.dart';
import '../exceptions/server_exception.dart';

/// 재사용 가능한 에러 표시 다이얼로그
/// 
/// 각 예외 타입에 따라 적절한 사용자 메시지를 표시합니다.
class ErrorDialog extends StatelessWidget {
  final Exception exception;
  final VoidCallback? onDismiss;
  
  const ErrorDialog({
    super.key,
    required this.exception,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo(exception);
    
    return AlertDialog(
      title: Text(errorInfo.title),
      content: Text(errorInfo.message),
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

  /// 예외 타입에 따른 에러 정보 추출
  _ErrorInfo _getErrorInfo(Exception exception) {
    if (exception is OAuthException) {
      return _ErrorInfo(
        title: 'OAuth 오류',
        message: exception.userMessage,
      );
    } else if (exception is NetworkException) {
      return _ErrorInfo(
        title: '네트워크 오류',
        message: exception.userMessage,
      );
    } else if (exception is ServerException) {
      return _ErrorInfo(
        title: '서버 오류',
        message: exception.userMessage,
      );
    } else {
      return _ErrorInfo(
        title: '오류',
        message: '알 수 없는 오류가 발생했습니다.',
      );
    }
  }

  /// 에러 다이얼로그를 표시하는 헬퍼 메서드
  static Future<void> show({
    required BuildContext context,
    required Exception exception,
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        exception: exception,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// 에러 스낵바를 표시하는 헬퍼 클래스
class ErrorSnackBar {
  /// 에러 스낵바를 표시하는 헬퍼 메서드
  static void show({
    required BuildContext context,
    required Exception exception,
    VoidCallback? onDismiss,
  }) {
    String message;
    
    if (exception is OAuthException) {
      message = exception.userMessage;
    } else if (exception is NetworkException) {
      message = exception.userMessage;
    } else if (exception is ServerException) {
      message = exception.userMessage;
    } else {
      message = '알 수 없는 오류가 발생했습니다.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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

/// 에러 정보를 담는 내부 클래스
class _ErrorInfo {
  final String title;
  final String message;
  
  const _ErrorInfo({
    required this.title,
    required this.message,
  });
}
