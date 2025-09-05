import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

class NavigationActions {
  NavigationActions(this._key);

  final GlobalKey<NavigatorState> _key;

  void navigateToSignup() {
    _key.currentState?.pushNamedAndRemoveUntil('/signup', (route) => false);
  }

  void navigateToHome() {
    _key.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void showSnackBar(String message) {
    final ctx = _key.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }
}
