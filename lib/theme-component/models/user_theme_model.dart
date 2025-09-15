import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/material.dart';

class UserTheme {
  final String name;
  final String path;
  final BoxFit fit;
  bool invertColors;
  Color? color;
  bool? isCustom;

  UserTheme({
    required this.name,
    required this.path,
    required this.fit,
    required this.invertColors,
    this.color,
    this.isCustom = true,
  });

  factory UserTheme.fromJson(Map<String, dynamic> json) => UserTheme(
        name: json['name'],
        path: json['path'],
        fit: json['fit'],
        invertColors: json['invertColors'],
        color: ColorHelper.fromString(json['color']),
      );

  static Map<String, dynamic> toJson(UserTheme theme) => {
        'name': theme.name,
        'path': theme.path,
        'fit': theme.fit,
        'invertColors': theme.invertColors,
        'color': theme.color.toString(),
      };
}
