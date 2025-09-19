import 'oauth_result.dart';

abstract class OAuthService<T> {
  String get providerId;
  
  String get displayName;

  bool get isSupported;
  
  T get config;

  Future<OAuthResult> signIn();

  Future<void> signOut();

  Future<void> initialize() async {}

  Future<void> dispose() async {}
}
