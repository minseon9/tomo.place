import 'error_interface.dart';
import 'error_codes.dart';
import 'error_types.dart';

/// 네트워크 관련 예외 클래스
/// 
/// 네트워크 연결 및 통신 과정에서 발생하는 예외를 처리합니다.
class NetworkException implements ErrorInterface {
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
  
  final int? statusCode;

  const NetworkException({
    required this.message,
    required this.userMessage,
    required this.title,
    required this.errorType,
    this.errorCode,
    this.suggestedAction,
    this.statusCode,
  });

  /// 연결 타임아웃
  factory NetworkException.connectionTimeout() {
    return const NetworkException(
      message: 'Connection timeout occurred',
      userMessage: '네트워크 연결 시간이 초과되었습니다. 다시 시도해주세요.',
      title: '연결 시간 초과',
      errorType: ErrorTypes.timeout,
      errorCode: ErrorCodes.connectionTimeout,
      suggestedAction: '네트워크 상태를 확인하고 다시 시도해주세요.',
    );
  }

  /// 서버 응답 타임아웃
  factory NetworkException.receiveTimeout() {
    return const NetworkException(
      message: 'Receive timeout occurred',
      userMessage: '서버 응답 시간이 초과되었습니다. 다시 시도해주세요.',
      title: '응답 시간 초과',
      errorType: ErrorTypes.timeout,
      errorCode: ErrorCodes.receiveTimeout,
      suggestedAction: '잠시 후 다시 시도해주세요.',
    );
  }

  /// 네트워크 연결 없음
  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No network connection available',
      userMessage: '네트워크 연결을 확인하고 다시 시도해주세요.',
      title: '네트워크 연결 없음',
      errorType: ErrorTypes.connection,
      errorCode: ErrorCodes.noConnection,
      suggestedAction: 'Wi-Fi 또는 모바일 데이터 연결을 확인해주세요.',
    );
  }

  /// DNS 해석 실패
  factory NetworkException.dnsResolutionFailed() {
    return const NetworkException(
      message: 'DNS resolution failed',
      userMessage: '서버 주소를 찾을 수 없습니다.',
      title: '서버 연결 실패',
      errorType: ErrorTypes.dns,
      errorCode: ErrorCodes.dnsResolutionFailed,
      suggestedAction: '인터넷 연결을 확인하고 다시 시도해주세요.',
    );
  }

  /// SSL/TLS 인증서 오류
  factory NetworkException.sslCertificateError() {
    return const NetworkException(
      message: 'SSL certificate error',
      userMessage: '보안 연결에 실패했습니다.',
      title: '보안 연결 오류',
      errorType: ErrorTypes.ssl,
      errorCode: ErrorCodes.sslCertificateError,
      suggestedAction: '앱을 업데이트하거나 관리자에게 문의하세요.',
    );
  }

  /// 요청 취소
  factory NetworkException.requestCancelled() {
    return const NetworkException(
      message: 'Request cancelled',
      userMessage: '요청이 취소되었습니다.',
      title: '요청 취소',
      errorType: ErrorTypes.requestResponse,
      errorCode: ErrorCodes.requestCancelled,
    );
  }

  /// 잘못된 응답
  factory NetworkException.badResponse() {
    return const NetworkException(
      message: 'Bad response received',
      userMessage: '서버에서 잘못된 응답을 받았습니다.',
      title: '응답 오류',
      errorType: ErrorTypes.requestResponse,
      errorCode: ErrorCodes.badResponse,
      suggestedAction: '잠시 후 다시 시도해주세요.',
    );
  }

  /// 연결 오류
  factory NetworkException.connectionError() {
    return const NetworkException(
      message: 'Connection error occurred',
      userMessage: '네트워크 연결에 오류가 발생했습니다.',
      title: '연결 오류',
      errorType: ErrorTypes.connection,
      errorCode: ErrorCodes.connectionError,
      suggestedAction: '네트워크 연결을 확인하고 다시 시도해주세요.',
    );
  }

  /// 보안 연결 실패
  factory NetworkException.securityConnectionFailed() {
    return const NetworkException(
      message: 'Security connection failed',
      userMessage: '보안 연결을 설정할 수 없습니다.',
      title: '보안 연결 실패',
      errorType: ErrorTypes.security,
      errorCode: ErrorCodes.securityConnectionFailed,
      suggestedAction: '네트워크 보안 설정을 확인하세요.',
    );
  }

  @override
  String toString() =>
      'NetworkException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}
