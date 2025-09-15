abstract interface class MessageSubscriber {
  Future<void>  handleMessageAsync<T>(String name, T message);
}
