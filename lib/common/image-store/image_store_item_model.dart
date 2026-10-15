import 'package:flutter/material.dart';
import 'dart:convert' as convert;

class ImageStoreItem {
  String? key;
  final String identifier;
  final String value;

  ImageStoreItem({
    this.key,
    required this.identifier,
    required this.value,
  }) {
    key = UniqueKey().toString();
  }

  factory ImageStoreItem.fromJson(Map<String, dynamic> json) => ImageStoreItem(
        key: json['key'],
        identifier: json['identifier'],
        value: json['value'],
      );

  static Map<String, dynamic> toJson(ImageStoreItem item) => {
        'key': item.key,
        'identifier': item.identifier,
        'value': item.value,
      };

  static String encode(ImageStoreItem item) => convert.json.encode(toJson(item));

  static ImageStoreItem decode(String jsonString) => ImageStoreItem.fromJson(
        convert.json.decode(jsonString),
      );
}
