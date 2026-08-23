import 'package:boombox/message-component/models/message_severity_enum.dart';

class AppNotification {
  final String title;
  final String message;
  final String notificationText;
  MessageSeverity severity;

  AppNotification({
    required this.title,
    required this.message,
    required this.notificationText,
    required this.severity,
  });
}
