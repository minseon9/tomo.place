import '../models/exception_interface.dart';

class GenericException implements ExceptionInterface {
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

  final dynamic originalException;

  const GenericException({
    required this.message,
    required this.userMessage,
    required this.title,
    required this.errorType,
    this.errorCode,
    this.suggestedAction,
    this.originalException,
  });

  /// 일반 Exception을 GenericException으로 변환
  factory GenericException.fromException(dynamic exception) {
    String message;
    String userMessage;

    if (exception is Exception || exception is Error) {
      message = exception.toString();
      userMessage = '예상치 못한 오류가 발생했습니다.';
    } else {
      message = exception?.toString() ?? 'Unknown error';
      userMessage = '알 수 없는 오류가 발생했습니다.';
    }

    return GenericException(
      message: message,
      userMessage: userMessage,
      title: '오류',
      errorType: 'Generic',
      errorCode: 'GEN_001',
      suggestedAction: '잠시 후 다시 시도해주세요.',
      originalException: exception,
    );
  }

  /// 네트워크 관련 예외를 GenericException으로 변환
  factory GenericException.fromNetworkException(dynamic exception) {
    return GenericException(
      message: exception.toString(),
      userMessage: '네트워크 오류가 발생했습니다.',
      title: '네트워크 오류',
      errorType: 'Network',
      errorCode: 'GEN_002',
      suggestedAction: '네트워크 연결을 확인하고 다시 시도해주세요.',
      originalException: exception,
    );
  }

  /// 서버 관련 예외를 GenericException으로 변환
  factory GenericException.fromServerException(dynamic exception) {
    return GenericException(
      message: exception.toString(),
      userMessage: '서버 오류가 발생했습니다.',
      title: '서버 오류',
      errorType: 'Server',
      errorCode: 'GEN_003',
      suggestedAction: '잠시 후 다시 시도해주세요.',
      originalException: exception,
    );
  }

  /// 인증 관련 예외를 GenericException으로 변환
  factory GenericException.fromAuthException(dynamic exception) {
    return GenericException(
      message: exception.toString(),
      userMessage: '인증 오류가 발생했습니다.',
      title: '인증 오류',
      errorType: 'Authentication',
      errorCode: 'GEN_004',
      suggestedAction: '다시 로그인해주세요.',
      originalException: exception,
    );
  }

  @override
  String toString() {
    return 'GenericException(message: $message, originalException: $originalException)';
  }
}
