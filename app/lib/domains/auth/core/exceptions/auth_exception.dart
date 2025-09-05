import '../../../../shared/error_handling/models/exception_interface.dart';
import 'error_codes.dart';
import 'error_types.dart';

class AuthException implements ExceptionInterface {
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

  final dynamic originalError;

  const AuthException({
    required this.message,
    required this.userMessage,
    required this.title,
    required this.errorType,
    this.errorCode,
    this.suggestedAction,
    this.originalError,
  });

  /// 인증 실패
  factory AuthException.authenticationFailed({
    required String message,
    String? code,
    dynamic originalError,
  }) {
    return AuthException(
      message: message,
      userMessage: '인증에 실패했습니다.',
      title: '인증 오류',
      errorType: AuthErrorTypes.authentication,
      errorCode: code ?? AuthErrorCodes.authenticationFailed,
      suggestedAction: '다시 로그인해주세요.',
      originalError: originalError,
    );
  }

  /// 권한 부족
  factory AuthException.insufficientPermissions({
    required String message,
    String? code,
    dynamic originalError,
  }) {
    return AuthException(
      message: message,
      userMessage: '접근 권한이 부족합니다.',
      title: '권한 오류',
      errorType: AuthErrorTypes.authorization,
      errorCode: code ?? AuthErrorCodes.insufficientPermissions,
      suggestedAction: '관리자에게 문의하세요.',
      originalError: originalError,
    );
  }

  /// 토큰 만료
  factory AuthException.tokenExpired({
    required String message,
    String? code,
    dynamic originalError,
  }) {
    return AuthException(
      message: message,
      userMessage: '인증 토큰이 만료되었습니다.',
      title: '토큰 만료',
      errorType: AuthErrorTypes.token,
      errorCode: code ?? AuthErrorCodes.tokenExpired,
      suggestedAction: '다시 로그인해주세요.',
      originalError: originalError,
    );
  }

  /// 계정 잠김
  factory AuthException.accountLocked({
    required String message,
    String? code,
    dynamic originalError,
  }) {
    return AuthException(
      message: message,
      userMessage: '계정이 잠겨있습니다.',
      title: '계정 잠김',
      errorType: AuthErrorTypes.account,
      errorCode: code ?? AuthErrorCodes.accountLocked,
      suggestedAction: '관리자에게 문의하세요.',
      originalError: originalError,
    );
  }

  /// 잘못된 인증 정보
  factory AuthException.invalidCredentials({
    required String message,
    String? code,
    dynamic originalError,
  }) {
    return AuthException(
      message: message,
      userMessage: '잘못된 인증 정보입니다.',
      title: '인증 정보 오류',
      errorType: AuthErrorTypes.authentication,
      errorCode: code ?? AuthErrorCodes.invalidCredentials,
      suggestedAction: '인증 정보를 확인하고 다시 시도해주세요.',
      originalError: originalError,
    );
  }

  /// 세션 만료
  factory AuthException.sessionExpired({
    required String message,
    String? code,
    dynamic originalError,
  }) {
    return AuthException(
      message: message,
      userMessage: '세션이 만료되었습니다.',
      title: '세션 만료',
      errorType: AuthErrorTypes.session,
      errorCode: code ?? AuthErrorCodes.sessionExpired,
      suggestedAction: '다시 로그인해주세요.',
      originalError: originalError,
    );
  }

  /// 계정 비활성화
  factory AuthException.accountDeactivated({
    required String message,
    String? code,
    dynamic originalError,
  }) {
    return AuthException(
      message: message,
      userMessage: '계정이 비활성화되었습니다.',
      title: '계정 비활성화',
      errorType: AuthErrorTypes.account,
      errorCode: code ?? AuthErrorCodes.accountDeactivated,
      suggestedAction: '관리자에게 문의하세요.',
      originalError: originalError,
    );
  }

  @override
  String toString() => 'AuthException: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          errorCode == other.errorCode;

  @override
  int get hashCode => message.hashCode ^ errorCode.hashCode;
}
