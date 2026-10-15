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
import 'package:boombox/player-component/models/trimmed_audio_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:flutter/material.dart';

class TrimAudioService with ChangeNotifier {
  late SharedPreferencesService _preferences;
  late List<TrimmedAudio> _songs;
  late bool _clipMode;

  late String _activeSong;

  static const String _TRIM_AUDIO_KEY = 'TRIM_AUDIO';

  late StreamController<TrimmedAudio> _trimmedStreamController;
  late StreamController<bool> _clipModeStreamController;
  Stream<TrimmedAudio> get getTrimmedAudioStream =>
      _trimmedStreamController.stream;
  Stream<bool> get getClipModeStream => _clipModeStreamController.stream;

  static final TrimAudioService _instance = TrimAudioService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory TrimAudioService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  TrimAudioService._internal() {
    _init();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _songs = [];
    _clipMode = false;
    _activeSong = '';

    _clipModeStreamController = StreamController.broadcast();
    _clipModeStreamController.sink.add(_clipMode);

    _trimmedStreamController = StreamController.broadcast();
    PlayerService().getSequenceStateStream.listen(
      (sequence) async {
        TrackInfo? info = sequence?.currentSource?.tag;
        if (info.isNull) return;
        _activeSong = info!.path!;
        if (_songs.isEmpty) return;

        List<TrimmedAudio> matches =
            _songs.where((song) => song.path.equals(info.path!)).toList();
        if (matches.isNotEmpty) return;
        _trimmedStreamController.sink.add(matches.first);
      },
    );

    try {
      _songs = TrimmedAudio.decode(await _preferences.readAsync(_TRIM_AUDIO_KEY));
    } on Exception catch (ex) {
      // Attempt to use Eternal storage
      String? result = await FileStorageService.readAsync<TrimmedAudio>();
      if (!result.isNull) {
        _songs = TrimmedAudio.decode(result!);
      }

      await Logger.logAsync(
        LogEvent<TrimAudioService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> addAudioTrimDataAsync({
    Duration? start,
    Duration? end,
  }) async {
    final List<String> paths = _songs.map((song) => song.path).toList();
    TrimmedAudio latest = TrimmedAudio(
      path: _activeSong,
      start: start,
      end: end,
    );

    if (paths.contains(_activeSong)) {
      final int index = paths.indexOf(_activeSong);
      final TrimmedAudio current = _songs.elementAt(index);
      latest = TrimmedAudio(
        path: current.path,
        start: start,
        end: end,
      );
      _songs.removeAt(index);
      _songs.insert(
        index,
        latest,
      );
    } else {
      _songs.add(latest);
    }

    await _saveToPreferences();
    await _saveToStorage();
    _trimmedStreamController.sink.add(latest);
  }

  Future<TrimmedAudio?> getTrimmedAudioDataAsync() async {
    List<String> paths = _songs.map((e) => e.path).toList();
    if (paths.isEmpty) return null;
    return _songs.elementAt(
      paths.indexOf(_activeSong),
    );
  }

  Future<void> setClipModeAsync(bool isActive) async {
    _clipMode = isActive;
    _clipModeStreamController.sink.add(_clipMode);
  }

  Future<bool > getClipModeAsync() async {
    return _clipMode;
  }

  Future<void> _saveToPreferences() async {
    try {
      await _preferences.saveAsync(_TRIM_AUDIO_KEY, TrimmedAudio.encode(_songs));
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<TrimAudioService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> _saveToStorage() async {
    await FileStorageService.writeStringAsync<TrimAudioService>(
      TrimmedAudio.encode(_songs),
      mode: FileMode.writeOnly,
    );
  }
}
