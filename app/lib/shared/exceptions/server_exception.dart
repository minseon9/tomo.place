import 'error_interface.dart';
import 'error_codes.dart';
import 'error_types.dart';

/// 서버 관련 예외 클래스
/// 
/// API 서버에서 반환하는 HTTP 에러 응답을 처리합니다.
class ServerException implements ErrorInterface {
  @override
  final String message; // For logging
  
  @override
  final String userMessage; // For UI display
  
  @override
  final String title; // Error title
  
  @override
  final String? errorCode;
  
  @override
  final String errorType;
  
  @override
  final String? suggestedAction;
  
  final int statusCode;
  
  const ServerException({
    required this.message,
    required this.userMessage,
    required this.title,
    required this.errorType,
    required this.statusCode,
    this.errorCode,
    this.suggestedAction,
  });

  /// 400 Bad Request
  factory ServerException.badRequest({
    required String message,
  }) {
    return ServerException(
      message: 'Bad request: $message',
      userMessage: '잘못된 요청입니다. 다시 시도해주세요.',
      title: '잘못된 요청',
      errorType: ErrorTypes.clientError,
      statusCode: 400,
      errorCode: ErrorCodes.badRequest,
      suggestedAction: '입력 정보를 확인하고 다시 시도해주세요.',
    );
  }

  /// 401 Unauthorized
  factory ServerException.unauthorized({
    required String message,
  }) {
    return ServerException(
      message: 'Unauthorized: $message',
      userMessage: '인증이 필요합니다. 다시 로그인해주세요.',
      title: '인증 필요',
      errorType: ErrorTypes.authentication,
      statusCode: 401,
      errorCode: ErrorCodes.unauthorized,
      suggestedAction: '다시 로그인해주세요.',
    );
  }

  /// 403 Forbidden
  factory ServerException.forbidden({
    required String message,
  }) {
    return ServerException(
      message: 'Forbidden: $message',
      userMessage: '접근 권한이 없습니다.',
      title: '접근 거부',
      errorType: ErrorTypes.authorization,
      statusCode: 403,
      errorCode: ErrorCodes.forbidden,
      suggestedAction: '관리자에게 문의하세요.',
    );
  }

  /// 404 Not Found
  factory ServerException.notFound({
    required String message,
  }) {
    return ServerException(
      message: 'Not found: $message',
      userMessage: '요청한 페이지를 찾을 수 없습니다.',
      title: '페이지 없음',
      errorType: ErrorTypes.resource,
      statusCode: 404,
      errorCode: ErrorCodes.notFound,
      suggestedAction: 'URL을 확인하고 다시 시도해주세요.',
    );
  }

  /// 500 Internal Server Error
  factory ServerException.internalServerError({
    required String message,
  }) {
    return ServerException(
      message: 'Internal server error: $message',
      userMessage: '서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      title: '서버 오류',
      errorType: ErrorTypes.serverError,
      statusCode: 500,
      errorCode: ErrorCodes.internalServerError,
      suggestedAction: '잠시 후 다시 시도해주세요.',
    );
  }

  /// 502 Bad Gateway
  factory ServerException.badGateway({
    required String message,
  }) {
    return ServerException(
      message: 'Bad gateway: $message',
      userMessage: '서버 연결 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      title: '서버 연결 오류',
      errorType: ErrorTypes.serverError,
      statusCode: 502,
      errorCode: ErrorCodes.badGateway,
      suggestedAction: '잠시 후 다시 시도해주세요.',
    );
  }

  /// 503 Service Unavailable
  factory ServerException.serviceUnavailable({
    required String message,
  }) {
    return ServerException(
      message: 'Service unavailable: $message',
      userMessage: '서비스를 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해주세요.',
      title: '서비스 일시 중단',
      errorType: ErrorTypes.serverError,
      statusCode: 503,
      errorCode: ErrorCodes.serviceUnavailable,
      suggestedAction: '잠시 후 다시 시도해주세요.',
    );
  }

  /// HTTP 상태 코드에 따른 자동 생성
  factory ServerException.fromStatusCode({
    required int statusCode,
    required String message,
  }) {
    String userMessage;
    String title;
    String errorType;
    String? errorCode;
    String? suggestedAction;
    
    if (statusCode >= 400 && statusCode < 500) {
      // Client errors
      errorType = ErrorTypes.clientError;
      switch (statusCode) {
        case 400:
          title = '잘못된 요청';
          userMessage = '잘못된 요청입니다. 다시 시도해주세요.';
          errorCode = ErrorCodes.badRequest;
          suggestedAction = '입력 정보를 확인하고 다시 시도해주세요.';
          break;
        case 401:
          title = '인증 필요';
          userMessage = '인증이 필요합니다. 다시 로그인해주세요.';
          errorCode = ErrorCodes.unauthorized;
          suggestedAction = '다시 로그인해주세요.';
          break;
        case 403:
          title = '접근 거부';
          userMessage = '접근 권한이 없습니다.';
          errorCode = ErrorCodes.forbidden;
          suggestedAction = '관리자에게 문의하세요.';
          break;
        case 404:
          title = '페이지 없음';
          userMessage = '요청한 페이지를 찾을 수 없습니다.';
          errorCode = ErrorCodes.notFound;
          suggestedAction = 'URL을 확인하고 다시 시도해주세요.';
          break;
        default:
          title = '클라이언트 오류';
          userMessage = '요청 처리 중 오류가 발생했습니다.';
          suggestedAction = '입력 정보를 확인하고 다시 시도해주세요.';
      }
    } else if (statusCode >= 500) {
      // Server errors
      errorType = ErrorTypes.serverError;
      title = '서버 오류';
      userMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      suggestedAction = '잠시 후 다시 시도해주세요.';
    } else {
      errorType = ErrorTypes.server;
      title = '알 수 없는 오류';
      userMessage = '알 수 없는 서버 오류가 발생했습니다.';
      suggestedAction = '관리자에게 문의하세요.';
    }

    return ServerException(
      message: 'HTTP $statusCode: $message',
      userMessage: userMessage,
      title: title,
      errorType: errorType,
      statusCode: statusCode,
      errorCode: errorCode,
      suggestedAction: suggestedAction,
    );
  }

  @override
  String toString() {
    return 'ServerException(statusCode: $statusCode, message: $message)';
  }
}
