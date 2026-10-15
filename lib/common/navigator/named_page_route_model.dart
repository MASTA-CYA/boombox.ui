import 'package:flutter/material.dart';

class NamedPageRoute {
  final String name;
  final Widget widget;
  final bool isRestorableRoute;
  final bool isHomeRoute;
  final List<String>? ancestors;

  const NamedPageRoute({
    required this.name,
    required this.widget,
    this.isRestorableRoute = false,
    this.isHomeRoute = false,
    this.ancestors,
  });

  String get path => '/$name';
}
