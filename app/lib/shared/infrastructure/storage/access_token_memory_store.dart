abstract class AccessTokenMemoryStoreInterface {
  void set(String token, DateTime expiresAt);

  String? get token;

  DateTime? get expiresAt;

  bool get hasValidToken;

  void clear();
}

class AccessTokenMemoryStore extends AccessTokenMemoryStoreInterface {
  String? _accessToken;
  DateTime? _expiresAt;

  @override
  void set(String token, DateTime expiresAt) {
    _accessToken = token;
    _expiresAt = expiresAt;
  }

  @override
  String? get token => _accessToken;

  @override
  DateTime? get expiresAt => _expiresAt;

  @override
  bool get hasValidToken {
    if (_accessToken == null || _expiresAt == null) return false;
    return DateTime.now().isBefore(_expiresAt!);
  }

  @override
  void clear() {
    _accessToken = null;
    _expiresAt = null;
  }
}
