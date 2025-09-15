import 'dart:io';

import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/regex_lookup.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/music-component/music_barrel.dart';
import 'package:boombox/recently-played-component/models/recent_song_model.dart';
import 'package:just_audio/just_audio.dart';

class RecentlyPlayedService with ChangeNotifier {
  late SharedPreferencesService _preferences;
  late List<RecentSong> _recentSongs;
  late List<Song> _songs;

  static const String _RECENTLY_PLAYED_KEY = 'RECENTLY_PLAYED';

  static final RecentlyPlayedService _instance =
      RecentlyPlayedService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory RecentlyPlayedService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  RecentlyPlayedService._internal() {
    _init();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _recentSongs = [];
    _songs = [];

    MusicService().getIsMappingStream.listen(
          (mappingResult) async =>
              mappingResult.isBusy ? null : await _loadSongsAsync(),
        );

    PlayerService()
        .getSequenceStateStream
        .listen((sequence) async => await _updateRecentlyPlayedAsync(sequence));
  }

  Future<void> _loadSongsAsync() async {
    try {
      _recentSongs = await RecentSong.decode(
        await _preferences.readAsync(_RECENTLY_PLAYED_KEY),
      );
    } on Exception catch (ex) {
      // Attempt to use Eternal storage
      String? result = await FileStorageService.readAsync<RecentSong>();
      if (!result.isNull) {
        _recentSongs = await RecentSong.decode(result!);
      }

      await Logger.logAsync(
        LogEvent<RecentlyPlayedService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    } finally {
      if (_recentSongs.isNotEmpty) {
        _recentSongs.sort(
          (a, b) => DateTime.parse(b.time).compareTo(
            DateTime.parse(a.time),
          ),
        );

        await PlayerService().loadRecentlyPlayedTracks(
          await getRecentlyPlayed(),
        );
      }
    }
  }

  Future<List<Song>> getRecentlyPlayed() async {
    if (_songs.isEmpty) {
      await _mapSongsAsync();
    }
    return _songs;
  }

  Future<void> _mapSongsAsync() async {
    int id = 0;
    for (RecentSong recent in _recentSongs) {
      if (!recent.song.path.contains(RegexLookup.Website)) {
        _songs.add(
          Song(
            id: id,
            path: recent.song.path,
            art: recent.song.art,
            name: recent.song.name,
            artist: recent.song.artist,
            duration: recent.song.duration,
            yearReleased: recent.song.yearReleased,
            genre: recent.song.genre,
            discNumber: recent.song.discNumber,
            mimeType: recent.song.mimeType,
            bitRate: recent.song.bitRate,
            dateAdded: recent.song.dateAdded,
          ),
        );
        id++;
      }
    }
  }

  Future<void> _updateRecentlyPlayedAsync(SequenceState? sequence) async {
    if (sequence.isNull) return;

    TrackInfo? info = sequence!.currentSource?.tag;
    if (info.isNull) return;
    if ((info!.path ?? '').contains(RegexLookup.Website)) return;

    // is track already on the list
    final bool wasPlayed = _recentSongs
        .map((song) => song.song.path)
        .toList()
        .contains(info.path ?? '');
    if (wasPlayed) {
      final RecentSong current = _recentSongs.firstWhere(
        (song) => song.song.path.equals(info.path!),
      );
      final int index = _recentSongs.indexOf(current);
      _recentSongs.removeAt(index);
      _recentSongs.insert(
        0,
        RecentSong(
          album: MusicService().getAlbumName(info.title!) ?? 'Unknown',
          song: current.song,
          time: DateTime.now().toIso8601String(),
        ),
      );
    } else {
      if (_recentSongs.isNotEmpty) {
        _recentSongs.insert(
          0,
          RecentSong(
            album: MusicService().getAlbumName(info.title!) ?? 'Unknown',
            song: Song(
              id: _recentSongs.last.song.id + 1,
              path: info.path!,
              art: info.art!,
              name: info.title!,
              artist: info.artist!,
              duration: info.duration!,
              yearReleased: info.year!,
              genre: info.genre!,
              dateAdded: info.dateAdded!,
              discNumber: info.discNumber!,
              mimeType: info.mimeType!,
              bitRate: info.bitRate!,
            ),
            time: DateTime.now().toIso8601String(),
          ),
        );
      } else {
        _recentSongs.add(
          RecentSong(
            album: MusicService().getAlbumName(info.title!) ?? 'Unknown',
            song: Song(
              id: 0,
              path: info.path!,
              art: info.art!,
              name: info.title!,
              artist: info.artist!,
              duration: info.duration!,
              yearReleased: info.year!,
              genre: info.genre!,
              dateAdded: info.dateAdded!,
              discNumber: info.discNumber!,
              mimeType: info.mimeType!,
              bitRate: info.bitRate!,
            ),
            time: DateTime.now().toIso8601String(),
          ),
        );
      }
    }

    _recentSongs = _recentSongs.take(15).toList();
    _songs = [];
    await _saveRecentlyPlayedAsync();
    await _mapSongsAsync();
    notifyListeners();
  }

  Future<void> _saveRecentlyPlayedAsync() async {
    await _preferences.saveAsync(
      _RECENTLY_PLAYED_KEY,
      RecentSong.encode(_recentSongs),
    );
    await FileStorageService.writeStringAsync<RecentSong>(
      RecentSong.encode(_recentSongs),
      mode: FileMode.writeOnly,
    );
  }
}
