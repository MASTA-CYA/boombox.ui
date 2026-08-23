import 'package:boombox/common/models/serializable_model.dart';
import 'package:boombox/message-component/models/message_severity_enum.dart';

import 'dart:convert' as convert;

class Message implements SerializableModel<Message> {
  int id;
  String date;
  String title;
  String body;
  MessageSeverity severity;
  bool hasBeenRead;
  bool hasBeenDismissed;
  bool hasBeenReported;

  Message({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    required this.severity,
    this.hasBeenRead = false,
    this.hasBeenDismissed = false,
    this.hasBeenReported = false,
  });

  @override
  List<String> get keys => toJson(this).keys.toList();

  @override
  Message get model => this;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: int.parse(json['id']),
        date: json['date'],
        title: json['title'],
        body: json['body'],
        severity: MessageSeverity.fromJson(json['severity']),
        hasBeenRead: json['hasBeenRead'],
        hasBeenDismissed: json['hasBeenDismissed'],
        hasBeenReported: json['hasBeenReported'],
      );

  static Map<String, dynamic> toJson(Message message) => {
        'id': message.id.toString(),
        'date': message.date,
        'title': message.title,
        'body': message.body,
        'severity': message.severity.toJson(),
        'hasBeenRead': message.hasBeenRead,
        'hasBeenDismissed': message.hasBeenDismissed,
        'hasBeenReported': message.hasBeenReported,
      };

  static String encode(List<Message> messages) => convert.json.encode(
        List<Map<String, dynamic>>.unmodifiable(
          messages
              .map<Map<String, dynamic>>((message) => Message.toJson(message)),
        ),
      );

  static List<Message> decode(String jsonString) =>
      (convert.json.decode(jsonString) as List<dynamic>)
          .map<Message>((parent) => Message.fromJson(parent))
          .toList();

  @override
  modifyProperty(String field, value) {
    Map<String, dynamic> source = toJson(this);
    if (source.containsKey(field)) {
      source[field] = value;
    }

    return Message.fromJson(source);
  }
}
