import 'dart:async';

import 'package:boombox/common/service-bus/models/stream_queue.dart';
import 'package:boombox/common/service-bus/strategy/message_strategy_interface.dart';

class StreamQueueStrategy implements MessageStrategy<StreamQueue> {
  StreamQueue registerQueue<T>(
      String queue, Map<String, StreamController<T>>? subscribers) {
    return StreamQueue(name: queue, subscribers: subscribers ?? {});
  }

  @override
  Future<void> sendMessageAsync<T>(StreamQueue queue, T message) async {
    for (StreamController subscriber in queue.subscribers.values) {
      await _broadcastMessageAsync<T>(subscriber, message);
    }
  }

  Future<void> _broadcastMessageAsync<T>(
    StreamController controller,
    T message,
  ) async {
    controller.sink.add(message);
  }
}
