import 'dart:async';

import '../exceptions/error_interface.dart';

class ErrorReporter {
  final StreamController<ErrorInterface> _controller = StreamController.broadcast();

  Stream<ErrorInterface> get stream => _controller.stream;

  void report(ErrorInterface error) => _controller.add(error);

  void dispose() => _controller.close();
}


