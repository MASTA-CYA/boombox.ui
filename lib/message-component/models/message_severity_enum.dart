import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:flutter/foundation.dart';

enum MessageSeverity {
  critical,
  information,
  warning,
  alert;

  factory MessageSeverity.fromLogEvent(Severity severity) => MessageSeverityExtension.messageSeverityFromLogEvent(severity);
  static MessageSeverity fromJson(String json) => values.byName(json);
  String toJson() => serializableName;
}

extension MessageSeverityExtension on MessageSeverity {
  String get name => describeEnum(this).capitalize();
  String get serializableName => describeEnum(this);
  static MessageSeverity messageSeverityFromLogEvent(Severity severity) {
    switch (severity) {
      case Severity.information:
        return MessageSeverity.information;
      case Severity.debug:
        return MessageSeverity.alert;
      case Severity.warning:
        return MessageSeverity.warning;
      case Severity.error:
        return MessageSeverity.critical;
    }
  }
}
