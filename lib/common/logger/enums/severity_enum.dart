import 'package:boombox/common/extensions.dart';
import 'package:flutter/foundation.dart';

enum Severity {
  information,
  debug,
  warning,
  error,
}

extension SeverityExtension on Severity {
  String get name {
    switch (this) {
      case Severity.information:
        return describeEnum(this).toUpperCase();
      case Severity.debug:
        return describeEnum(this).toUpperCase();
      case Severity.warning:
        return describeEnum(this).toUpperCase();
      case Severity.error:
        return describeEnum(this).toUpperCase();
      }
  }

  String get messageName {
    switch (this) {
      case Severity.information:
        return describeEnum(this).capitalize();
      case Severity.debug:
        return describeEnum(this).capitalize();
      case Severity.warning:
        return describeEnum(this).capitalize();
      case Severity.error:
        return describeEnum(this).capitalize();
    }
  }
}
