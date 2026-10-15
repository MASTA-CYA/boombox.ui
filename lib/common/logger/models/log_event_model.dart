import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';

class LogEvent<T> {
  final String time = DateTime.now().toIso8601String();
  final Severity severity;
  final Tag tag;
  final String line;
  final StackTrace? stacktrace;

  LogEvent({
    required this.severity,
    required this.tag,
    required this.line,
    this.stacktrace,
  });

  String get caller => '$T';

  String stackTrace() {
    if (stacktrace.isNull) return line;
    return stacktrace!.toString();
  }

  @override
  String toString() {
    return '\n$time [$T] [${tag.name}] [${severity.name}] $line';
  }
}
