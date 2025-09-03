import 'dart:async';

enum SessionEvent { expired, signedOut }

class SessionEventBus {
  final StreamController<SessionEvent> _controller = StreamController.broadcast();

  Stream<SessionEvent> get stream => _controller.stream;

  void publish(SessionEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}


