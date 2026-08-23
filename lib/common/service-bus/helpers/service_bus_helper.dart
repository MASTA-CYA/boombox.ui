import 'package:boombox/common/service-bus/models/message_subscriber_interface.dart';
import 'package:boombox/common/service-bus/service_bus.dart';

class ServiceBusHelper {
  static MessageSubscriber? getServiceInstance(String key) {
    final List<Map<String, MessageSubscriber>> serviceMap =
        ServiceBus().services.where((map) => map.keys.contains(key)).toList();
    if (serviceMap.isEmpty) return null;
    return serviceMap.first[key];
  }
}
