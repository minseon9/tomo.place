class AccessTokenMemoryStore {
  String? _accessToken;
  DateTime? _expiresAt;

  void set(String token, DateTime expiresAt) {
    _accessToken = token;
    _expiresAt = expiresAt;
  }

  String? get token => _accessToken;

  DateTime? get expiresAt => _expiresAt;

  bool get hasValidToken {
    if (_accessToken == null || _expiresAt == null) return false;
    return DateTime.now().isBefore(_expiresAt!);
  }

  void clear() {
    _accessToken = null;
    _expiresAt = null;
  }
}
