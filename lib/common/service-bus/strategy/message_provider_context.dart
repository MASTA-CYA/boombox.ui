import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/service-bus/strategy/message_strategy_interface.dart';

class MessageProvider {
  MessageStrategy? _messageStrategy;

  set setStrategy(MessageStrategy strategy) => _messageStrategy = strategy;

  MessageProvider();
  factory MessageProvider.fromStrategy({required MessageStrategy strategy}) {
    final MessageProvider provider = MessageProvider();
    provider._messageStrategy = strategy;
    return provider;
  }

  Future<dynamic> broadcastMessageAsync<T, K>(T queue, K message) async {
    if (_messageStrategy.isNull) return [];
    return await _messageStrategy!.sendMessageAsync<K>(queue, message);
  }
}
