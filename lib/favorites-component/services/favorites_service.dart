import 'dart:async';
import 'dart:io';

import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

class FavoritesService with ChangeNotifier {
  late SharedPreferencesService _preferences;
  late List<String> _songs;

  String? _path;

  static const String _FAVORITES_KEY = 'FAVORITES_KEY';

  late StreamController<bool> _favoriteStreamController;
  Stream<bool> get getIsFavoriteStream => _favoriteStreamController.stream;

  static final FavoritesService _instance = FavoritesService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory FavoritesService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  FavoritesService._internal() {
    _init();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _songs = [];

    _favoriteStreamController = StreamController<bool>.broadcast();
    PlayerService().getSequenceStateStream.listen(
      (sequence) async {
        TrackInfo? info = sequence?.currentSource?.tag;
        if (info.isNull) return;
        _path = info!.path!;
        _favoriteStreamController.sink.add(await isFavoriteAsync());
      },
    );

    try {
      _songs = (convert.json.decode(
        await _preferences.readAsync(_FAVORITES_KEY),
      ) as List<dynamic>)
          .cast<String>();
    } on Exception catch (ex) {
      // Attempt to use Eternal storage
      String? result = await FileStorageService.readAsync<FavoritesService>();
      if (!result.isNull) {
        _songs = (convert.json.decode(result!) as List<dynamic>).cast<String>();
      }

      await Logger.logAsync(
        LogEvent<FavoritesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<bool> isFavoriteAsync() async {
    return _songs.contains(_path);
  }

  Future<void> addOrRemovedFavoriteAsync() async {
    await isFavoriteAsync()
        ? _songs.remove(_path)
        : _path.isNull
            ? null
            : _songs.add(_path!);
    await _saveToPreferences();
    await _saveToStorage();
    _favoriteStreamController.sink.add(await isFavoriteAsync());
  }

  Future<void> _saveToPreferences() async {
    try {
      await _preferences.saveAsync(_FAVORITES_KEY, convert.json.encode(_songs));
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<FavoritesService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> _saveToStorage() async {
    await FileStorageService.writeStringAsync<FavoritesService>(
      convert.json.encode(_songs),
      mode: FileMode.writeOnly,
    );
  }
}
