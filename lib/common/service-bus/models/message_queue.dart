import 'package:boombox/common/service-bus/models/service_bus_queue.dart';

class MessageQueue implements ServiceBusQueue {
  @override
  final String name;
  final List<String> subscribers;

  const MessageQueue({
    required this.name,
    required this.subscribers,
  });
}
