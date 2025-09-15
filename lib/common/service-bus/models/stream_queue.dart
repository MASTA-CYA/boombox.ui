import 'dart:async';

import 'package:boombox/common/service-bus/models/service_bus_queue.dart';

class StreamQueue<T> implements ServiceBusQueue {
  @override
  final String name;
  final Map<String, StreamController<T>> subscribers;

  const StreamQueue({
    required this.name,
    required this.subscribers,
  });
}
