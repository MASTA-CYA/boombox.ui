import 'dart:io';

import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/message-component/models/message_severity_enum.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:flutter/foundation.dart';

class Logger {
  static Future logAsync(
    LogEvent event, {
    bool shouldSaveMessage = false,
  }) async {
    String logLine = event.severity.equals(Severity.error)
        ? event.stackTrace()
        : event.toString();
    if (!kReleaseMode) debugPrint(logLine);
    await FileStorageService.writeStringAsync<Logger>(logLine);

    if (shouldSaveMessage) {
      await MessageService().saveMessageAsync(
        '${event.severity.messageName} event on ${event.caller}',
        event.line,
        MessageSeverity.fromLogEvent(event.severity),
      );
    }
  }

  static Future<File> getLogFileAsync<T>() async {
    await logAsync(
      LogEvent<Logger>(
        severity: Severity.information,
        tag: Tag.service,
        line: '$T requested the application log file',
      ),
    );

    return await FileStorageService.getFileInstanceAsync<Logger>();
  }

  static Future<void> dumpLogFileAsync() async {
    final String? contents = await FileStorageService.readAsync<Logger>();
    if (contents.isNull) {
      await logAsync(
        LogEvent<Logger>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Unable to read contents of log file.',
        ),
      );
      return;
    }

    final DateTime date = DateTime.now();
    String fileName = '${date.year}${date.month}${date.day}T'
        '${date.hour}${date.minute}${date.second}';
    await FileStorageService.writeStringAsync<Logger>(contents!, key: fileName);
  }
}
