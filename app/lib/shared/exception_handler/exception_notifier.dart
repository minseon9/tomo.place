import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exceptions/unknown_exception.dart';
import 'models/exception_interface.dart';

class ExceptionNotifier extends StateNotifier<ExceptionInterface?> {
  ExceptionNotifier() : super(null);

  void report(error) {
    if (error is ExceptionInterface) {
      state = error;
    } else {
      state = UnknownException(message: error.toString());
    }
  }

  void clear() => state = null;
}

final exceptionNotifierProvider =
    StateNotifierProvider<ExceptionNotifier, ExceptionInterface?>(
      (ref) => ExceptionNotifier(),
    );
