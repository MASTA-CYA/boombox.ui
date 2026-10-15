abstract interface class MessageStrategy<T> {
  Future<void> sendMessageAsync<K>(T queue, K message);
}
