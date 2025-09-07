import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/exception_interface.dart';

class ExceptionNotifier extends StateNotifier<ExceptionInterface?> {
  ExceptionNotifier() : super(null);

  void report(ExceptionInterface error) => state = error;

  void clear() => state = null;
}

final exceptionNotifierProvider =
    StateNotifierProvider<ExceptionNotifier, ExceptionInterface?>(
      (ref) => ExceptionNotifier(),
    );
