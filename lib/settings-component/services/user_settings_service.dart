import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/settings-component/models/enums/storage_source_enum.dart';
import 'package:boombox/settings-component/models/user_settings_model.dart';
import 'package:boombox/theme-component/models/user_theme_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

class UserSettingsService with ChangeNotifier {
  static const String _USER_SETTINGS_KEY = 'SETTINGS';

  late SharedPreferencesService _preferences;
  static UserSettings? _settings;

  late StreamController<bool> _lyricsController;
  late StreamController<bool> _storageController;
  late StreamController<StorageSource> _storageSourceController;
  late StreamController<bool> _mediaController;
  late StreamController<bool> _equalizerController;
  late StreamController<bool> _newsController;
  late StreamController<bool> _appFeaturesController;
  late StreamController<int> _onlineController;
  late StreamController<UserTheme> _activeThemeController;
  late StreamController<List<String>> _enabledFeaturesController;

  Stream<bool> get getCanSaveLyricsLocallyStream => _lyricsController.stream;
  Stream<bool> get getUseEternalStorageStream => _storageController.stream;
  Stream<StorageSource> get getStorageSourceStream =>
      _storageSourceController.stream;
  Stream<bool> get getCanDownloadArtistMediaStream => _mediaController.stream;
  Stream<bool> get getUseSmartEqualizerStream => _equalizerController.stream;
  Stream<bool> get getCanFetchNewsStream => _newsController.stream;
  Stream<bool> get getCanShowApplicationFeaturesStream =>
      _appFeaturesController.stream;
  Stream<int> get getOnlineCapabilitiesStream => _onlineController.stream;
  Stream<UserTheme> get getActiveThemeStream => _activeThemeController.stream;
  Stream<List<String>> get getEnabledFeaturesStream =>
      _enabledFeaturesController.stream;

  static bool? get useEternalStorage => _settings?.useEternalStorage;
  static StorageSource get storageSource =>
      _settings?.storageSource ?? StorageSource.automatic;
  static bool get canSaveLyricsLocally =>
      _settings?.canSaveLyricsLocally ?? false;
  static bool get canDownloadArtistMedia =>
      _settings?.canDownloadArtistMedia ?? false;
  static bool get useSmartEqualizer => _settings?.useSmartEqualizer ?? false;
  static bool get canFetchNews => _settings?.canFetchNews ?? false;
  static Brightness get isDarkTheme =>
      _settings?.isDarkTheme ?? Brightness.dark;

  static final UserSettingsService _instance = UserSettingsService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory UserSettingsService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  UserSettingsService._internal() {
    _init();
  }

  @override
  void dispose() async {
    await _lyricsController.close();
    await _storageController.close();
    await _storageSourceController.close();
    await _mediaController.close();
    await _equalizerController.close();
    await _newsController.close();
    await _appFeaturesController.close();
    await _onlineController.close();
    await _activeThemeController.close();
    await _enabledFeaturesController.close();
    super.dispose();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _lyricsController = StreamController<bool>.broadcast();
    _storageController = StreamController<bool>.broadcast();
    _storageSourceController = StreamController<StorageSource>.broadcast();
    _mediaController = StreamController<bool>.broadcast();
    _equalizerController = StreamController<bool>.broadcast();
    _appFeaturesController = StreamController<bool>.broadcast();
    _newsController = StreamController<bool>.broadcast();
    _onlineController = StreamController<int>.broadcast();
    _activeThemeController = StreamController<UserTheme>.broadcast();
    _enabledFeaturesController = StreamController.broadcast();

    try {
      String value = await _preferences.readAsync(_USER_SETTINGS_KEY);
      _settings = UserSettings.fromJson(
        (json.decode(value)) as Map<String, dynamic>,
      );
    } on Exception catch (e) {
      debugPrint(e.toString());

      String? result = await FileStorageService.readAsync<UserSettings>();
      if (!result.isNull) {
        _settings = UserSettings.fromJson(
          (json.decode(result!)) as Map<String, dynamic>,
        );
      }
    } finally {
      _settings = _settings ?? UserSettings();

      StreamGroup.mergeBroadcast([
        _lyricsController.stream,
        _mediaController.stream,
        _equalizerController.stream,
        _newsController.stream,
      ]).asBroadcastStream().listen(
        (hasCapabilities) {
          List<String> features = [];
          int count = 0;
          if (_settings!.canSaveLyricsLocally ?? false) {
            features.add('Lyrics');
            count++;
          }
          if (_settings!.canDownloadArtistMedia ?? false) {
            features.add('Media');
            count++;
          }
          if (_settings!.useSmartEqualizer ?? false) {
            features.add('Equalizer');
            count++;
          }
          if (_settings!.canFetchNews ?? false) {
            features.add('News');
            count++;
          }
          _enabledFeaturesController.sink.add(features);
          _onlineController.sink.add(count);
        },
      );

      _lyricsController.sink.add(_settings?.canSaveLyricsLocally ?? false);
      _storageController.sink.add(_settings?.useEternalStorage ?? false);
      _storageSourceController.sink
          .add(_settings?.storageSource ?? StorageSource.automatic);
      _mediaController.sink.add(_settings?.canDownloadArtistMedia ?? false);
      _equalizerController.sink.add(_settings?.useSmartEqualizer ?? false);
      _newsController.sink.add(_settings?.canFetchNews ?? false);
      _activeThemeController.sink.add(await getActiveThemeAsync());

      notifyListeners();
    }
  }

  Future<UserSettings> getUserSettingsAsync() async {
    if (_settings.isNull) await _init();
    return _settings!;
  }

  Future<bool> getCanSaveLyricsLocallyAsync() async {
    return _settings?.canSaveLyricsLocally ?? false;
  }

  Future<void> updateCanSaveLyricsLocallyAsync(bool canSave) async {
    try {
      _settings!.canSaveLyricsLocally = canSave;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
      _lyricsController.add(canSave);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<bool> getUseEternalStorageAsync() async {
    return _settings?.useEternalStorage ?? false;
  }

  Future<void> updateUseEternalStorageAsync(bool canUse) async {
    try {
      _settings!.useEternalStorage = canUse;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
      _storageController.sink.add(canUse);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<StorageSource> getStorageSourceAsync() async {
    return _settings?.storageSource ?? StorageSource.automatic;
  }

  Future<void> updateStorageSourceAsync(StorageSource source) async {
    try {
      _settings!.storageSource = source;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
      _storageSourceController.sink.add(source);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<bool> getCanDownloadArtistMediaAsync() async {
    return _settings?.canDownloadArtistMedia ?? false;
  }

  Future<void> updateCanDownloadArtistMediaAsync(bool canDownload) async {
    try {
      _settings!.canDownloadArtistMedia = canDownload;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
      _mediaController.sink.add(canDownload);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<bool> getUseSmartEqualizerAsync() async {
    return _settings?.useSmartEqualizer ?? false;
  }

  Future<void> updateUseSmartEqualizerAsync(bool canUse) async {
    try {
      _settings!.useSmartEqualizer = canUse;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
      _equalizerController.sink.add(canUse);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<bool> getCanShowApplicationFeaturesAsync() async {
    return _settings?.canShowApplicationFeatures ?? false;
  }

  Future<void> updateCanShowApplicationFeaturesAsync(bool canShow) async {
    try {
      _settings!.canShowApplicationFeatures = canShow;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
      _appFeaturesController.sink.add(canShow);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<bool> getCanFetchNewsAsync() async {
    return _settings?.canFetchNews ?? false;
  }

  Future<void> updateCanFetchNewsAsync(bool canFetch) async {
    try {
      _settings!.canFetchNews = canFetch;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      _newsController.sink.add(canFetch);
      await _saveToStorage();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<int> getOnlineCapabilitiesAsync() async {
    int count = 0;
    if (_settings!.canSaveLyricsLocally ?? false) count++;
    if (_settings!.canDownloadArtistMedia ?? false) count++;
    if (_settings!.useSmartEqualizer ?? false) count++;
    if (_settings!.canFetchNews ?? false) count++;

    return count;
  }

  Future<UserTheme> getActiveThemeAsync() async {
    return _settings!.theme ??
        UserTheme(
          name: '80s Party',
          path: 'assets/images/themes/80s Party.png',
          fit: BoxFit.fill,
          invertColors: true,
          isCustom: true,
        );
  }

  Future<void> updateActiveThemeAsync(UserTheme theme) async {
    try {
      _settings!.theme = theme;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
      _activeThemeController.sink.add(theme);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> updateHasOnlineCapabilitiesAsync(bool hasCapability) async {
    await updateCanSaveLyricsLocallyAsync(hasCapability);
    await updateCanDownloadArtistMediaAsync(hasCapability);
    await updateUseSmartEqualizerAsync(hasCapability);
    await updateCanFetchNewsAsync(hasCapability);
  }

  Future<void> updateApplicationThemeAsync(Brightness brightness) async {
    try {
      _settings!.isDarkTheme = brightness;
      await _preferences.saveAsync(
        _USER_SETTINGS_KEY,
        json.encode(UserSettings.toJson(_settings!)),
      );
      await _saveToStorage();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<UserSettingsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  static Future<Brightness> getApplicationThemeFromStorageAsync() async {
    if (_settings?.isDarkTheme?.isNull ?? true) {
      String? result = await FileStorageService.readAsync<UserSettings>();
      if (!result.isNull) {
        _settings = UserSettings.fromJson(
          (json.decode(result!)) as Map<String, dynamic>,
        );
      }
    }

    return _settings?.isDarkTheme ?? Brightness.dark;
  }

  Future<void> _saveToStorage() async {
    await FileStorageService.writeStringAsync<UserSettings>(
      convert.json.encode(UserSettings.toJson(_settings!)),
      mode: FileMode.writeOnly,
    );
  }
}
