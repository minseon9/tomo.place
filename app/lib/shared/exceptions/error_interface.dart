abstract class ErrorInterface implements Exception {
  /// 로깅용 에러 메시지 (개발자/디버깅용)
  String get message;

  /// 사용자에게 표시할 에러 메시지 (한국어)
  String get userMessage;

  /// 에러 제목 (UI에서 사용)
  String get title;

  /// 에러 코드 (선택사항)
  String? get errorCode;

  /// 에러 타입 (카테고리 분류용)
  String get errorType;

  /// 사용자 액션 제안 (선택사항)
  String? get suggestedAction;
}
