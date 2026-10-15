import 'dart:async';
import 'dart:io';

import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/models/persistable_service.dart';
import 'package:boombox/common/models/serializable_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/message-component/models/message_model.dart';
import 'package:boombox/message-component/models/message_severity_enum.dart';
import 'package:boombox/message-component/models/notification_model.dart';
import 'package:flutter/material.dart';

class MessageService with ChangeNotifier implements PersistableService {
  static const String _MESSAGES_KEY = 'MESSAGES_KEY';

  late SharedPreferencesService _preferences;
  late List<SerializableModel<Message>> _messages;

  late StreamController<AppNotification> _notificationStreamController;
  Stream<AppNotification> get getNotificationStream =>
      _notificationStreamController.stream;

  static final MessageService _instance = MessageService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory MessageService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  MessageService._internal() {
    _init();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _messages = [];

    _notificationStreamController =
        StreamController<AppNotification>.broadcast();

    try {
      _messages = Message.decode(
        await _preferences.readAsync(_MESSAGES_KEY),
      );
    } on Exception catch (ex) {
      // Attempt to use Eternal storage
      String? result = await FileStorageService.readAsync<MessageService>();
      if (!result.isNull) {
        _messages = Message.decode(result!);
      }

      await Logger.logAsync(
        LogEvent<MessageService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> sendNotificationAsync(
    AppNotification notification, {
    bool saveAsMessage = true,
  }) async {
    _notificationStreamController.sink.add(notification);
    if (saveAsMessage) {
      await saveMessageAsync(
        notification.title,
        notification.message,
        notification.severity,
      );
    }
  }

  Future<void> saveMessageAsync(
    String title,
    String body,
    MessageSeverity severity,
  ) async {
    _messages.add(
      Message(
        id: _getNextId(),
        date: DateTime.now().toIso8601String(),
        title: title,
        body: body,
        severity: severity,
      ),
    );
    notifyListeners();
  }

  Future<List<SerializableModel<Message>>> getMessagesAsync() async {
    List<SerializableModel<Message>> messages = _messages
        .where(
          (message) => !message.model.hasBeenDismissed,
        )
        .toList();
    messages.sort(
      ((a, b) =>
          DateTime.parse(a.model.date).compareTo(DateTime.parse(b.model.date))),
    );

    return messages;
  }

  Future<SerializableModel<Message>> getMessageAsync(int id) async {
    return _messages.firstWhere(
      (message) => message.model.id == id,
      orElse: () => _messages.first.model,
    );
  }

  Future<int> getMessageCountAsync() async {
    return (await getMessagesAsync()).length;
  }

  Future<int> getUnreadMessageCountAsync() async {
    return _messages
        .where(
          (message) =>
              !message.model.hasBeenRead && !message.model.hasBeenDismissed,
        )
        .length;
  }

  Future<bool> getMessageReadStatus(int id) async {
    return _messages
        .firstWhere(
          (message) => message.model.id == id,
          orElse: () => _messages.first.model,
        )
        .model
        .hasBeenRead;
  }

  Future<bool> getMessageReportStatus(int id) async {
    return _messages
        .firstWhere(
          (message) => message.model.id == id,
          orElse: () => _messages.first.model,
        )
        .model
        .hasBeenReported;
  }

  Future<void> readMessageAsync(int id) async {
    _messages.modifyElement(
      find: (element) => element.model.id == id,
      property: 'hasBeenRead',
      value: true,
    );
    await saveChangesAsync<MessageService>(shouldNotifyListeners: true);
  }

  Future<void> readAllMessagesAsync() async {
    for (SerializableModel<Message> message in _messages.where(
      (message) => !message.model.hasBeenRead,
    )) {
      _messages.modifyElement(
        find: (element) => element.model.id == message.model.id,
        property: 'hasBeenRead',
        value: true,
      );
    }
    await saveChangesAsync<MessageService>(shouldNotifyListeners: true);
  }

  Future<void> reportMessageAsync(int id) async {
    _messages.modifyElement(
      find: (element) => element.model.id == id,
      property: 'hasBeenReported',
      value: true,
    );
    await saveChangesAsync<MessageService>(shouldNotifyListeners: true);
  }

  Future<void> dismissMessageAsync(int id) async {
    _messages.modifyElement(
      find: (element) => element.model.id == id,
      property: 'hasBeenDismissed',
      value: true,
    );
    await saveChangesAsync<MessageService>();
  }

  Future<void> dismissAllMessagesAsync() async {
    for (SerializableModel<Message> message in _messages.where(
      (message) => !message.model.hasBeenDismissed,
    )) {
      _messages.modifyElement(
        find: (element) => element.model.id == message.model.id,
        property: 'hasBeenDismissed',
        value: true,
      );
    }
    await saveChangesAsync<MessageService>();
  }

  @override
  Future<void> saveChangesAsync<T>({
    bool shouldNotifyListeners = false,
  }) async {
    await _saveToPreferences();
    await _saveToStorage();
    if (shouldNotifyListeners) notifyListeners();
  }
  
  Future<void> _saveToPreferences() async {
    try {
      await _preferences.saveAsync(_MESSAGES_KEY,
          Message.encode(_messages.map((e) => e.model).toList()));
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<MessageService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> _saveToStorage() async {
    await FileStorageService.writeStringAsync<MessageService>(
      Message.encode(_messages.map((e) => e.model).toList()),
      mode: FileMode.writeOnly,
    );
  }

  int _getNextId() => _messages.isNotEmpty ? _messages.last.model.id + 1 : 0;

  
}
