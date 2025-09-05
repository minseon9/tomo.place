import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/exception_interface.dart';

class ErrorEffects extends StateNotifier<ExceptionInterface?> {
  ErrorEffects() : super(null);

  void report(ExceptionInterface error) => state = error;

  void clear() => state = null;
}

final errorEffectsProvider =
    StateNotifierProvider<ErrorEffects, ExceptionInterface?>(
      (ref) => ErrorEffects(),
    );
