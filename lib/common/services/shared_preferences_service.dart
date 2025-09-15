import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  SharedPreferences? _preferences;

  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory SharedPreferencesService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  SharedPreferencesService._internal();

  Future _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<String> readAsync(String key) async {
    if (_preferences == null) {
      await _initPreferences();
    }

    try {
      if (_preferences!.containsKey(key)) {
        return json.decode(_preferences!.getString(key) ?? '');
      } else {
        throw Exception('Key not found: $key');
      }
    } on Exception catch (e) {
      await Logger.logAsync(
        LogEvent<SharedPreferencesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: e.toString(),
        ),
      );
      debugPrint(e.toString());
      await Logger.logAsync(
        LogEvent<SharedPreferencesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Unable to retrieve data for key: $key',
        ),
      );
      rethrow;
    }
  }

  Future saveAsync(String key, value) async {
    if (_preferences == null) {
      await _initPreferences();
    }

    try {
      _preferences!.setString(key, json.encode(value));
    } on Exception catch (e) {
      await Logger.logAsync(
        LogEvent<SharedPreferencesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: e.toString(),
        ),
      );
      debugPrint(e.toString());
      await Logger.logAsync(
        LogEvent<SharedPreferencesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Unable to save data for key: $key',
        ),
      );
      rethrow;
    }
  }

  Future removeAsync(String key) async {
    if (_preferences == null) {
      await _initPreferences();
    }

    try {
      if (_preferences!.containsKey(key)) {
        _preferences!.remove(key);
      } else {
        throw Exception('Key not found: $key');
      }
    } on Exception catch (e) {
      await Logger.logAsync(
        LogEvent<SharedPreferencesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: e.toString(),
        ),
      );
      debugPrint(e.toString());
      await Logger.logAsync(
        LogEvent<SharedPreferencesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Unable to remove data for key: $key',
        ),
      );
      rethrow;
    }
  }

  Future<bool> containsKey(String key) async {
    if (_preferences == null) {
      await _initPreferences();
    }
    return _preferences?.containsKey(key) ?? false;
  }
}
