// ignore_for_file: unused_field

import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/music-component/services/metadata_service.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:equalizer_flutter/equalizer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EqualizerService with ChangeNotifier {
  late SharedPreferencesService _preferences;

  List<int>? _lsBandRange;
  late List<String> _lsEqualizerPresets;
  late List<String> _lsUserPresets;
  late List<int> _lsFrequencies;
  late bool _isInitialized;

  String? _activePreset;
  Map<int, double>? _activeBandLevels;
  int? sessionId;

  static final EqualizerService _instance = EqualizerService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory EqualizerService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  EqualizerService._internal() {
    _init();
  }

  @override
  void dispose() {
    EqualizerFlutter.release();
    super.dispose();
  }

  Future _init() async {
    _preferences = SharedPreferencesService();
    _lsFrequencies = [];
    await _getCustomPresetsAsync();

    PlayerService().getAudioSessionStream.listen(
      (id) {
        if (sessionId.isNull || !id.isNull) sessionId = id;
      },
    );
    PlayerService().getSequenceStateStream.listen(
      (sequence) async {
        String? genre;
        TrackInfo? info = sequence?.currentSource?.tag;
        if (info.isNull) return;
        if (info!.genre.isNull) return;
        if (!UserSettingsService.useSmartEqualizer) return;
        if (!_isInitialized) {
          if (sessionId.isNull) return;
          await initEqualizerAsync(sessionId!);
        }
        if (info.genre!.equals('Unknown')) {
          genre = await MetaDataService().getTrackGenreAsync(
            info.title ?? '',
            info.artist ?? '',
          );
        }
        await _synchronizeEqualizer(genre ?? info.genre!);
      },
    );

    _isInitialized = false;
  }

  Future initEqualizerAsync(int audioSessionId) async {
    try {
      EqualizerFlutter.init(audioSessionId);
      EqualizerFlutter.setEnabled(true);

      // Band range
      _lsBandRange = await EqualizerFlutter.getBandLevelRange();
      debugPrint('----------------------------------------------------');
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Band Range Count: ${_lsBandRange!.length.toString()}',
        ),
      );
      debugPrint('Band Range Count: ${_lsBandRange!.length.toString()}');
      debugPrint('----------------------------------------------------');
      for (int i = 0; i < _lsBandRange!.length; i++) {
        await Logger.logAsync(
          LogEvent<EqualizerService>(
            severity: Severity.information,
            tag: Tag.service,
            line: '$i: ${_lsBandRange!.elementAt(i).toString()}',
          ),
        );
        debugPrint('$i: ${_lsBandRange!.elementAt(i).toString()}');
      }

      // Presets
      _lsEqualizerPresets = await EqualizerFlutter.getPresetNames();
      debugPrint('----------------------------------------------------');
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Preset Count: ${_lsEqualizerPresets.length.toString()}',
        ),
      );
      debugPrint('Preset Count: ${_lsEqualizerPresets.length.toString()}');
      debugPrint('----------------------------------------------------');
      for (int i = 0; i < _lsEqualizerPresets.length; i++) {
        await Logger.logAsync(
          LogEvent<EqualizerService>(
            severity: Severity.information,
            tag: Tag.service,
            line: '$i: ${_lsEqualizerPresets.elementAt(i)}',
          ),
        );
        debugPrint('$i: ${_lsEqualizerPresets.elementAt(i)}');
      }

      // Frequencies
      _lsFrequencies = await EqualizerFlutter.getCenterBandFreqs();
      debugPrint('----------------------------------------------------');
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Frequencies Count: ${_lsFrequencies.length.toString()}',
        ),
      );
      debugPrint('Frequencies Count: ${_lsFrequencies.length.toString()}');
      debugPrint('----------------------------------------------------');
      for (int i = 0; i < _lsFrequencies.length; i++) {
        await Logger.logAsync(
          LogEvent<EqualizerService>(
            severity: Severity.information,
            tag: Tag.service,
            line: '$i: ${_lsFrequencies.elementAt(i).toString()}',
          ),
        );
        debugPrint('$i: ${_lsFrequencies.elementAt(i).toString()}');
      }

      //
      _activePreset = _lsUserPresets.first;
      _activeBandLevels = {};
      _isInitialized = true;
    } on PlatformException {
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Frequencies Count: ${_lsFrequencies.length.toString()}',
        ),
      );
      // rethrow;
    }
  }

  // Presets
  Future _getCustomPresetsAsync() async {
    _lsUserPresets = [
      'Flat',
      'Bass Boost',
      'Hip Hop',
      'Rock',
      'Jazz',
      'Custom'
    ];
  }

  Future<List<String>> getPresetsAsync() async {
    return _lsUserPresets;
  }

  Future<bool> setPresetAsync(String preset) async {
    bool wasSuccess = false;
    try {
      EqualizerFlutter.setPreset(preset);
      _activePreset = preset;
      await _getBandLevelsAsync();
      wasSuccess = true;
      notifyListeners();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }

    return wasSuccess;
  }

  // Frequency Bands
  Future _getBandLevelsAsync() async {
    Map<int, double> bandLevels = {};

    try {
      for (var i = 0; i < _lsFrequencies.length; i++) {
        bandLevels.addAll(
          {
            i: (await EqualizerFlutter.getBandLevel(i)).toDouble(),
          },
        );
      }
      _activeBandLevels = bandLevels;
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<Map<int, double>> getActiveBandLevelsAsync() async {
    if (_activeBandLevels!.isEmpty) {
      await _getBandLevelsAsync();
    }

    return _activeBandLevels!;
  }

  Future<bool> setBandLevelAsync(int bandId, int level) async {
    bool wasSuccess = false;
    try {
      await EqualizerFlutter.setBandLevel(
        bandId,
        level,
      );
      wasSuccess = true;
      notifyListeners();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }

    return wasSuccess;
  }

  Future<List<int>> getBandRangeAsync() async {
    return _lsBandRange ?? [-15, 15];
  }

  Future<void> _synchronizeEqualizer(String genre) async {
    String preset = _lsEqualizerPresets.firstWhere(
      (preset) => preset.containsIgnoreCase(genre),
      orElse: () => '',
    );

    // No preset found
    if (preset.isEmpty) return;

    try {
      EqualizerFlutter.setPreset(preset);
      _activePreset = preset;
      Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Smart Equalizer switched to preset: $preset',
        ),
      );
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<EqualizerService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }
}
