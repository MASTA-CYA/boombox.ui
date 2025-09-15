import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/service-bus/helpers/service_bus_helper.dart';
import 'package:boombox/common/service-bus/models/message_queue.dart';
import 'package:boombox/common/service-bus/models/message_subscriber_interface.dart';
import 'package:boombox/common/service-bus/strategy/message_strategy_interface.dart';

class MessageQueueStrategy implements MessageStrategy<MessageQueue> {
  @override
  Future<void> sendMessageAsync<T>(MessageQueue queue, T message) async {
    for (String subscriber in queue.subscribers) {
      final MessageSubscriber? service =
          ServiceBusHelper.getServiceInstance(subscriber);
      await _broadcastMessageAsync<T>(subscriber, message, service);
    }
  }

  Future<void> _broadcastMessageAsync<T>(
      String name, T message, MessageSubscriber? service) async {
    if (service.isNull) {
      Logger.logAsync(
        LogEvent<MessageQueueStrategy>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'No match for $name',
        ),
      );
    } else {
      service!.handleMessageAsync<T>(name, message);
    }
  }
}
