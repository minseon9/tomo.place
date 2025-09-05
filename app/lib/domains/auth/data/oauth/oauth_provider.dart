import 'oauth_result.dart';

abstract class OAuthProvider {
  String get providerId;

  String get displayName;

  bool get isSupported;

  Future<OAuthResult> signIn();

  Future<void> signOut();

  Future<void> initialize() async {}

  Future<void> dispose() async {}
}
