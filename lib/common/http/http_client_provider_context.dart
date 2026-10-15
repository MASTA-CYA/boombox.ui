import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

class HttpClientProvider {
  Client? _httpStrategy;

  set setStrategy(Client strategy) => _httpStrategy = strategy;

  HttpClientProvider();
  factory HttpClientProvider.fromStrategy({required Client strategy}) {
    final HttpClientProvider provider = HttpClientProvider();
    provider._httpStrategy = strategy;
    return provider;
  }

  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    return await _httpStrategy!.get(url, headers: headers);
  }

  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return await _httpStrategy!.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    // TODO: implement head
    throw UnimplementedError();
  }

  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement patch
    throw UnimplementedError();
  }

  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement put
    throw UnimplementedError();
  }

  Future<String> read(Uri url, {Map<String, String>? headers}) {
    // TODO: implement read
    throw UnimplementedError();
  }

  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    // TODO: implement readBytes
    throw UnimplementedError();
  }

  Future<StreamedResponse> send(BaseRequest request) {
    // TODO: implement send
    throw UnimplementedError();
  }

  void close() => _httpStrategy!.close();
}
