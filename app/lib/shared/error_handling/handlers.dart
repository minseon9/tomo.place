import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/exception_interface.dart';
import 'providers.dart';

/// 에러 처리 헬퍼 클래스
class ErrorHandlers {
  /// 에러를 UI에 표시하는 핸들러
  static void handleError(
    ExceptionInterface error, {
    required WidgetRef ref,
    String? customMessage,
  }) {
    // ErrorEffects에 에러 상태 설정
    ref.read(errorEffectsProvider.notifier).report(error);

    // 추가적인 UI 처리 (스낵바 등)가 필요한 경우 여기서 처리
    // 현재는 ErrorEffects Provider를 통해 상태만 관리
  }

  /// 에러 상태 초기화
  static void clearError(WidgetRef ref) {
    ref.read(errorEffectsProvider.notifier).clear();
  }

  /// 네트워크 에러 처리
  static void handleNetworkError(
    String message, {
    required WidgetRef ref,
    String? customMessage,
  }) {
    // TODO: NetworkException 생성 및 처리
    // 현재는 기본 에러 처리
    handleError(
      _createGenericError(message),
      ref: ref,
      customMessage: customMessage,
    );
  }

  /// 서버 에러 처리
  static void handleServerError(
    String message, {
    required WidgetRef ref,
    String? customMessage,
  }) {
    // TODO: ServerException 생성 및 처리
    // 현재는 기본 에러 처리
    handleError(
      _createGenericError(message),
      ref: ref,
      customMessage: customMessage,
    );
  }

  /// 기본 에러 생성 (임시)
  static ExceptionInterface _createGenericError(String message) {
    return _GenericError(message);
  }
}

/// 임시 Generic Error 구현
class _GenericError implements ExceptionInterface {
  final String _message;

  _GenericError(this._message);

  @override
  String get message => _message;

  @override
  String get userMessage => '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get title => '오류';

  @override
  String? get errorCode => null;

  @override
  String get errorType => 'Generic';

  @override
  String? get suggestedAction => null;
}
