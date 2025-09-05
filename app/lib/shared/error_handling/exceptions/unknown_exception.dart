import '../models/exception_interface.dart';

class UnknownException implements ExceptionInterface {
  const UnknownException({
    required this.message,
    this.userMessage = '알 수 없는 오류가 발생했습니다.',
    this.title = '오류',
    this.errorCode,
    this.errorType = 'unknown',
    this.suggestedAction = '잠시 후 다시 시도해주세요.',
  });

  @override
  final String message;

  @override
  final String userMessage;

  @override
  final String title;

  @override
  final String? errorCode;

  @override
  final String errorType;

  @override
  final String? suggestedAction;
}
