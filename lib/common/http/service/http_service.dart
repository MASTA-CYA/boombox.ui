import 'package:boombox/common/http/http_client_provider_context.dart';
import 'package:boombox/common/http/interceptors/logging_interceptor.dart';
import 'package:boombox/common/http/strategies/smart_http_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

class HttpService with ChangeNotifier {
  late Client _client;
  late HttpClientProvider _httpProvider;

  Client get client => _client;

  static final HttpService _instance = HttpService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory HttpService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  HttpService._internal() {
    _init();
  }

  Future<void> _init() async {
    _httpProvider = HttpClientProvider();
    _client = InterceptedClient.build(
      interceptors: [
        LoggingInterceptor(),
      ],
      requestTimeout: const Duration(seconds: 20),
      // client: _client,
    );
    _configureStrategy();
  }

  Future<Response> getAsync<T extends Client>(Uri url,
      {Map<String, String>? headers}) async {
    _configureStrategy<T>();
    return await _httpProvider.get(url, headers: headers);
  }

  void _configureStrategy<T extends Client>() {
    switch (T) {
      case SmartHttpClientStrategy:
        _httpProvider.setStrategy = SmartHttpClientStrategy(client: _client);
        break;
      default:
        _httpProvider.setStrategy = _client;
    }
  }
}
