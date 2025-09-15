import 'dart:async';

import 'package:boombox/common/service-bus/models/message_queue.dart';
import 'package:boombox/common/service-bus/models/message_subscriber_interface.dart';
import 'package:boombox/common/service-bus/models/service_bus_queue.dart';
import 'package:boombox/common/service-bus/models/stream_queue.dart';
import 'package:boombox/common/service-bus/strategy/message_provider_context.dart';
import 'package:boombox/common/service-bus/strategy/message_queue_strategy.dart';
import 'package:boombox/common/service-bus/strategy/stream_queue_strategy.dart';
import 'package:boombox/commons_barrel.dart';

class ServiceBus {
  late List<Map<String, MessageSubscriber>> _services;
  late List<ServiceBusQueue> _queues;
  late MessageProvider _provider;

  List<Map<String, MessageSubscriber>> get services => _services;

  static final ServiceBus _instance = ServiceBus._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory ServiceBus() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  ServiceBus._internal() {
    _services = [];
    _queues = [];
    _provider = MessageProvider();
  }

  Future<void> registerServiceAsync(
    String name,
    MessageSubscriber service,
  ) async {
    _services.add({name: service});
  }

  Future<void> registerMessageQueueAsync(
    String name, {
    List<String>? subscribers,
  }) async {
    _queues.add(
      MessageQueue(
        name: name,
        subscribers: subscribers ?? [],
      ),
    );
  }

  Future<void> registerMessageSubscriberAsync(
    String message,
    String name,
  ) async {
    final MessageQueue messageQueue = _queues
        .cast<MessageQueue>()
        .firstWhere((queue) => queue.name.equals(message));
    messageQueue.subscribers.add(name);
    _queues.replaceElement(
      find: (queue) => (queue as MessageQueue).name.equals(message),
      element: messageQueue,
    );
  }

  Future<Map<String, StreamController<T>>> registerStreamQueueAsync<T>(
    String name,
    List<String> subscribers,
  ) async {
    Map<String, StreamController<T>> map = {};

    for (String subscriber in subscribers) {
      map.addAll({subscriber: StreamController<T>.broadcast()});
    }

    _queues.add(
      StreamQueue(
        name: name,
        subscribers: map,
      ),
    );

    return map;
  }

  Future<Stream<T>> registerStreamSubscriberAsync<T>(
      String name, String key) async {
    final StreamQueue streamQueue = _queues
        .cast<StreamQueue>()
        .firstWhere((queue) => queue.name.equals(name));
    final Map<String, StreamController> controller;
    if (streamQueue.subscribers.containsKey(key)) {
      controller = {key: StreamController<T>.broadcast()};
      streamQueue.subscribers.addAll(controller);
      _queues.replaceElement(
        find: (queue) => (queue as StreamQueue).name.equals(name),
        element: streamQueue,
      );
    } else {
      controller = streamQueue.subscribers;
    }
    return controller[key]!.stream.cast<T>();
  }

  Future<void> sendMessageAsync<T>(String name, T message) async {
    final ServiceBusQueue queue =
        _queues.firstWhere((queue) => queue.name.equals(name));

    switch (queue.runtimeType) {
      case MessageQueue:
        _provider.setStrategy = MessageQueueStrategy();
        _provider.broadcastMessageAsync<MessageQueue, T>(
          queue as MessageQueue,
          message,
        );
        break;
      default:
        if (queue is StreamQueue<T>) {
          _provider.setStrategy = StreamQueueStrategy();
          _provider.broadcastMessageAsync<StreamQueue, T>(
              queue as StreamQueue, message);
        } else {
          Logger.logAsync(
            LogEvent<MessageQueueStrategy>(
              severity: Severity.information,
              tag: Tag.service,
              line: 'No strategy found for ${queue.runtimeType}',
            ),
          );
        }
    }
  }
}
