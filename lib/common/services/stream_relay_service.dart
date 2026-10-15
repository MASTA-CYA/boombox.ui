class StreamRelayService {
  
  static final StreamRelayService _instance =
    StreamRelayService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory StreamRelayService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  StreamRelayService._internal() {}
}