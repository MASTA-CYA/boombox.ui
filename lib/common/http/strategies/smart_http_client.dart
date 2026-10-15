import 'dart:convert';

import 'dart:typed_data';

import 'package:boombox/common/services/connectivity_service.dart';
import 'package:http/http.dart';

class SmartHttpClientStrategy implements Client {
  final Client client;

  SmartHttpClientStrategy({required this.client});

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    if (!await ConnectivityService().hasNetworkConnectivityAsync()) {
      throw Exception('No network connectivity');
    }
    return await client.get(url, headers: headers);
  }

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    if (!await ConnectivityService().hasNetworkConnectivityAsync()) {
      throw Exception('No network connectivity');
    }
    return await client.post(url,
        headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    // TODO: implement head
    throw UnimplementedError();
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement patch
    throw UnimplementedError();
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement put
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    // TODO: implement readBytes
    throw UnimplementedError();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    // TODO: implement send
    throw UnimplementedError();
  }

  @override
  void close() => client.close();
}
