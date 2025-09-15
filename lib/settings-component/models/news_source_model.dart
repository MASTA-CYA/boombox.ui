import 'dart:convert' as convert;

import 'package:boombox/common/models/serializable_model.dart';

class NewsSource implements SerializableModel<NewsSource> {
  final String image;
  final String name;
  final String url;
  final bool isSelected;

  const NewsSource({
    required this.image,
    required this.name,
    required this.url,
    this.isSelected = false,
  });
  
  @override
  NewsSource get model => this;
  
  @override
  List<String> get keys => toJson(this).keys.toList();

  factory NewsSource.fromJson(Map<String, dynamic> json) => NewsSource(
        image: json['image'],
        name: json['name'],
        url: json['url'],
        isSelected: json['isSelected'],
      );

  static Map<String, dynamic> toJson(NewsSource sources) => {
        'image': sources.image,
        'name': sources.name,
        'url': sources.url,
        'isSelected': sources.isSelected,
      };

  static String encode(List<NewsSource> sources) => convert.json.encode(
        sources
            .map<Map<String, dynamic>>((source) => NewsSource.toJson(source))
            .toList(),
      );

  static List<NewsSource> decode(String jsonString) =>
      (convert.json.decode(jsonString) as List<dynamic>)
          .map<NewsSource>((source) => NewsSource.fromJson(source))
          .toList();

  @override
  NewsSource modifyProperty(String field, dynamic value) {
    Map<String, dynamic> source = toJson(this);
    if (source.containsKey(field)) {
      source[field] = value;
    }

    return NewsSource.fromJson(source);
  }
}
