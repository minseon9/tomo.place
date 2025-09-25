import '../../../../shared/exception_handler/models/exception_interface.dart';
import 'error_codes.dart';
import 'error_types.dart';

class LocationException implements ExceptionInterface {
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

  const LocationException({
    required this.message,
    required this.userMessage,
    required this.title,
    required this.errorType,
    this.errorCode,
    this.suggestedAction,
    this.originalError,
  });

  factory LocationException.permissionDenied({
    required String message,
    dynamic originalError,
  }) {
    return LocationException(
      message: message,
      userMessage: '위치 권한이 거부되었습니다.',
      title: '위치 권한 오류',
      errorType: MapErrorTypes.location,
      errorCode: MapErrorCodes.permissionDenied,
      suggestedAction: '설정에서 위치 권한을 허용해주세요.',
      originalError: originalError,
    );
  }

  factory LocationException.notFound({
    required String message,
    dynamic originalError,
  }) {
    return LocationException(
      message: message,
      userMessage: '현재 위치를 찾을 수 없습니다.',
      title: '위치 오류',
      errorType: MapErrorTypes.location,
      errorCode: MapErrorCodes.notFound,
      suggestedAction: '잠시 후 다시 시도해주세요.',
      originalError: originalError,
    );
  }


  @override
  String toString() => 'LocationException: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocationException &&
              runtimeType == other.runtimeType &&
              message == other.message &&
              errorCode == other.errorCode;

  @override
  int get hashCode => message.hashCode ^ errorCode.hashCode;

}
