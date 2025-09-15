import 'dart:io';
import 'dart:typed_data';

import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlaylistService with ChangeNotifier {
  static const String _PLAYLISTS_KEY = 'PLAYLISTS';

  late SharedPreferencesService _preferences;
  late List<Playlist> _playlists;
  late int _playlistIdentity;

  static final PlaylistService _instance = PlaylistService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory PlaylistService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  PlaylistService._internal() {
    _init();
  }

  Future _init() async {
    _preferences = SharedPreferencesService();
    _playlists = [];
    _playlistIdentity = 0;

    await _getPlaylists();
  }

  Future _getPlaylists() async {
    try {
      _playlists = Playlist.decode(
        await _preferences.readAsync(_PLAYLISTS_KEY),
      );
      _playlistIdentity =
          _playlists.last.id == 0 ? _playlists.length - 1 : _playlists.last.id;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> _savePlaylists() async {
    bool wasSuccessful = false;

    try {
      await _preferences.saveAsync(_PLAYLISTS_KEY, Playlist.encode(_playlists));
      await FileStorageService.writeStringAsync<Playlist>(
        Playlist.encode(_playlists),
        mode: FileMode.writeOnly,
      );
      wasSuccessful = true;
    } on Exception {
      wasSuccessful = true;
    }

    return wasSuccessful;
  }

  Future<List<Playlist>> getPlaylistsAsync() async {
    if (_playlists.isEmpty) {
      await _getPlaylists();
    }

    return _playlists;
  }

  Future<bool> addPlaylistAsync(Uint8List? image, String name, int tracks,
      List<PlaylistSong> songs) async {
    bool wasSuccessful = false;

    _playlists.add(
      Playlist(
          id: _playlistIdentity++,
          date: DateFormat.yMd().format(DateTime.now()),
          name: name,
          tracks: tracks,
          songs: songs),
    );

    wasSuccessful = await _savePlaylists();
    notifyListeners();

    return wasSuccessful;
  }

  Future<bool> editPlaylistAsync(int id, String date, Uint8List? image,
      String name, int tracks, List<PlaylistSong> songs) async {
    bool wasSuccessful = false;

    final Playlist playlist = _playlists.firstWhere((p) => p.id == id);
    int index = _playlists.indexOf(playlist);
    _playlists.removeAt(index);
    _playlists.insert(
      index,
      Playlist(
        id: id,
        date: date,
        name: name,
        tracks: tracks,
        songs: songs,
      ),
    );

    wasSuccessful = await _savePlaylists();
    notifyListeners();

    return wasSuccessful;
  }

  Future<bool> addSongToPlaylistAsync(Playlist playlist, Song song) async {
    bool wasSuccessful = false;

    try {
      int index = _playlists.indexOf(playlist);
      Playlist oldPlaylist = _playlists.elementAt(index);
      oldPlaylist.songs.add(PlaylistSong(song: song));
      _playlists.removeAt(index);
      _playlists.insert(index, oldPlaylist);

      await _savePlaylists();
      notifyListeners();
      wasSuccessful = true;
    } on Exception catch (ex) {
      Logger.logAsync(
        LogEvent<PlaylistService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }

    return wasSuccessful;
  }

  Future<bool> removePlaylistAsync(Playlist playlist) async {
    bool wasSuccessful;

    final int index = _playlists.indexOf(playlist);
    _playlists.removeAt(index);
    wasSuccessful = await _savePlaylists();
    notifyListeners();

    return wasSuccessful;
  }
}
