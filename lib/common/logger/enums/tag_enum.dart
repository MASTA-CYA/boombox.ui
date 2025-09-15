import 'package:boombox/common/extensions.dart';
import 'package:flutter/foundation.dart';

enum Tag {
  application,
  http,
  service,
  widget,
  extension,
  observer,
  helper,
  strategy,
  handler,
}

extension TagExtension on Tag {
  String get name {
    switch (this) {
      case Tag.application:
      case Tag.http:
      case Tag.service:
      case Tag.widget:
      case Tag.extension:
      case Tag.observer:
      case Tag.helper:
      case Tag.strategy:
        return describeEnum(this).toUpperCase();
      default:
        return "UNKNOWN";
    }
  }

  String get messageName {
    switch (this) {
      case Tag.application:
      case Tag.http:
      case Tag.service:
      case Tag.widget:
      case Tag.extension:
      case Tag.observer:
      case Tag.helper:
      case Tag.handler:
        return describeEnum(this).capitalize();
      default:
        return "Unknown";
    }
  }
}
