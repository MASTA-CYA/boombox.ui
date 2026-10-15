import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:boombox/common/image-store/image_store_service.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/regex_lookup.dart';
import 'package:boombox/common/service-bus/service_bus.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/directory-component/models/directory_listing_model.dart';
import 'package:boombox/message-component/models/message_severity_enum.dart';
import 'package:boombox/message-component/models/notification_model.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/models/enums/sort_option_order_enum.dart';
import 'package:boombox/music-component/models/folder_model.dart';
import 'package:boombox/music-component/models/mapping_result_model.dart';
import 'package:boombox/music-component/models/media_category_interface.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/music-component/services/media_art_service.dart';
import 'package:boombox/music-component/services/media_store_service.dart';
import 'package:boombox/music-component/services/metadata_service.dart';
import 'package:boombox/music-component/strategy/album_search_strategy.dart';
import 'package:boombox/music-component/strategy/artist_search_strategy.dart';
import 'package:boombox/music-component/strategy/search_provider_context.dart';
import 'package:boombox/music-component/strategy/search_strategy_interface.dart';
import 'package:boombox/music-component/strategy/song_search_strategy.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

class MusicService with ChangeNotifier {
  static const String _MEDIA_DIRECTORIES_LISTING_KEY = 'DIRECTORIES_LISTING';
  static const String _MAPPED_ALBUMS_KEY = 'MAPPED_ALBUMS';
  static const String _MAPPING_STATUS = 'LIBRARY_MAPPING_STATUS';

  late SharedPreferencesService _preferences;
  late List<DirectoryListing> _directories;
  late bool _isBusyMapping;

  late SearchProvider _searchProvider;

  late List<Folder> _folders;
  late List<Song> _songs;
  late List<Album> _albums;
  late List<Artist> _artists;

  late StreamController<MappingResult> _isMappingStreamController;
  Stream<MappingResult> get getIsMappingStream =>
      _isMappingStreamController.stream;

  static final MusicService _instance = MusicService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory MusicService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  MusicService._internal() {
    _init();
  }

  Future _init() async {
    _preferences = SharedPreferencesService();
    _searchProvider = SearchProvider();
    _isBusyMapping = false;
    _directories = [];
    _folders = [];
    _songs = [];
    _albums = [];
    _artists = [];

    _isMappingStreamController = StreamController<MappingResult>.broadcast();

    try {
      await ServiceBus().registerMessageQueueAsync(_MAPPING_STATUS);
      await _loadDirectoriesAsync();
      await _loadLibrariesAsync();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<MusicService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
      await _sendMappingNotificationAsync(
        "Mapping failed",
        MessageSeverity.alert,
      );
    }
  }

  Future<bool> isBusyMapping() async => _isBusyMapping;

  Future _loadDirectoriesAsync() async {
    try {
      _directories = DirectoryListing.decode(
        await _preferences.readAsync(_MEDIA_DIRECTORIES_LISTING_KEY),
      );
    } on Exception catch (ex) {
      // Attempt to use Eternal storage
      String? result = await FileStorageService.readAsync<DirectoryListing>();
      if (!result.isNull) {
        _directories = DirectoryListing.decode(result!);
      }

      await Logger.logAsync(
        LogEvent<MusicService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> _loadLibrariesAsync() async {
    DateTime start, end;

    start = DateTime.now();
    _isBusyMapping = true;
    // await ServiceBus().sendMessageAsync<String>(
    //   _MAPPING_STATUS,
    //   'Mapping started.',
    // );
    await _sendMappingNotificationAsync(
      "Mapping started",
      MessageSeverity.information,
    );
    await _mapAlbumsAsync();
    // await ServiceBus().sendMessageAsync<String>(
    //   _MAPPING_STATUS,
    //   'Mapping albums done.',
    // );
    await _mapSongsAsync();
    // await ServiceBus().sendMessageAsync<String>(
    //   _MAPPING_STATUS,
    //   'Mapping songs done.',
    // );
    await _mapArtistsAsync();
    // await ServiceBus().sendMessageAsync<String>(
    //   _MAPPING_STATUS,
    //   'Mapping artists done.',
    // );
    _isBusyMapping = false;
    end = DateTime.now();

    // Save mappings
    _saveMappingsToStorage<Album>();

    // log duration
    final Duration duration = end.difference(start);
    final String timeTaken = DateFormat(
      'mm:ss',
    ).format(DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds));
    final String result = 'Mapping libraries took $timeTaken';
    final String title =
        'Mapping the music library '
        '${_getTimeAnalytics(duration.inMilliseconds)}';
    final String message =
        '$result'
        '\nSongs: ${_songs.length}'
        '\nAlbums: ${_albums.length}'
        '\nArtists: ${_artists.length}'
        '\nFolders: ${_folders.length}';
    final MessageSeverity severity = _getTimeSeverity(duration.inMilliseconds);

    _updateMappingResult(_isBusyMapping, title, message, result, severity);
    Logger.logAsync(
      LogEvent<MusicService>(
        severity: Severity.information,
        tag: Tag.service,
        line: result,
      ),
    );
  }

  Future<List<Folder>> getFoldersAsync() async {
    if (_folders.isEmpty) {
      await _mapFoldersAsync();
    }

    return _folders;
  }

  Future<void> _mapFoldersAsync() async {
    _folders = [];

    for (DirectoryListing listing in _directories) {
      String name = listing.path.split('/').last;
      if (name.contains('SongsLover')) {
        List<String> split = name.split('-')..removeLast();
        name = split.join('-').trim();
      }

      _folders.add(
        Folder(
          path: listing.path,
          name: name,
          folders: 1,
          items: listing.files.length,
        ),
      );
    }
  }

  Future<List<Song>> getSongsAsync(
    MapEntry<String?, SortOptionOrder> map,
  ) async {
    if (_songs.isEmpty) {
      await _mapSongsAsync();
    }

    // Early return when no filter
    if (map.value == SortOptionOrder.none) return _songs;

    // Has filter
    List<Song> sortedSongs = _songs.map((song) => song).toList();
    switch (map.key) {
      case 'Name':
        sortedSongs.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name),
        );
        break;
      case 'Added':
        sortedSongs.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.dateAdded.compareTo(b.dateAdded)
                  : b.dateAdded.compareTo(a.dateAdded),
        );
        break;
      case 'Date':
        sortedSongs.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.yearReleased.compareTo(b.yearReleased)
                  : b.yearReleased.compareTo(a.yearReleased),
        );
        break;
      case 'Duration':
        sortedSongs.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.duration.compareTo(b.duration)
                  : b.duration.compareTo(a.duration),
        );
        break;
      default:
        sortedSongs = _songs;
        break;
    }

    return sortedSongs;
  }

  Future<void> _mapSongsAsync() async {
    for (Album album in _albums) {
      _songs.addAll(album.songs);
    }
  }

  Future<List<Album>> getAlbumsAsync(
    MapEntry<String?, SortOptionOrder> map,
  ) async {
    if (_albums.isEmpty) {
      await _mapAlbumsAsync();
    }

    // Early return when no filter
    if (map.value == SortOptionOrder.none) return _albums;

    // Has filter
    List<Album> sortedAlbums = _albums.map((album) => album).toList();
    switch (map.key) {
      case 'Name':
        sortedAlbums.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name),
        );
        break;
      case 'Added':
        sortedAlbums.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.songs.first.dateAdded.compareTo(b.songs.first.dateAdded)
                  : b.songs.first.dateAdded.compareTo(a.songs.first.dateAdded),
        );
        break;
      case 'Date':
        sortedAlbums.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.year.compareTo(b.year)
                  : b.year.compareTo(a.year),
        );
        break;
      case 'Duration':
        sortedAlbums.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.songs
                      .map((song) => song.duration)
                      .toList()
                      .reduce((value, element) => value + element)
                      .compareTo(
                        b.songs
                            .map((song) => song.duration)
                            .toList()
                            .reduce((value, element) => value + element),
                      )
                  : b.songs
                      .map((song) => song.duration)
                      .toList()
                      .reduce((value, element) => value + element)
                      .compareTo(
                        a.songs
                            .map((song) => song.duration)
                            .toList()
                            .reduce((value, element) => value + element),
                      ),
        );
        break;
      default:
        sortedAlbums = _albums;
        break;
    }

    return sortedAlbums;
  }

  Future<List<Album>> getAlbumsByArtistAsync(String artist) async {
    if (_albums.isEmpty) {
      await _mapAlbumsAsync();
    }

    return _albums.where((album) => album.artist.equals(artist)).toList();
  }

  Future<void> _mapAlbumsAsync() async {
    _isBusyMapping = true;
    if (_directories.isEmpty) {
      await _loadDirectoriesAsync();
    }

    await _mapLocalAlbumsAsync();
    // await _mapOnlineAlbumsAsync();
  }

  Future<void> _mapLocalAlbumsAsync() async {
    final String? result = await _loadFromStorageAsync<Album>();
    if (!result.isNull) {
      _albums = await Album.decode(result!);
    } else {
      int albumId = 0;
      int songId = 0;
      String? cover;
      Uint8List? art;
      String album = '';
      String artist = 'Unknown';
      int year = 0;
      List<Song> songs = [];
      bool isSingle;
      int skippedFileCount = 0;
      int skippedDirectoryCount = 0;

      // loop through directories
      for (DirectoryListing listing in _directories) {
        try {
          // get album name from directory
          if (listing.path.contains('SongsLover')) {
            album = listing.path.split(' - ').elementAt(1);
          }

          // check for singles directory
          final String folderName = listing.path.split('/').last;
          isSingle = folderName.equals('Singles');

          // attempt to get cover image from directory
          cover = _getCoverFromDirectory(listing);

          // loop through files
          for (String file in listing.files) {
            if (_isFileImage(file) || !_isFileAudio(file)) continue;

            try {
              Metadata meta = await MetadataRetriever.fromFile(File(file));
              // sanitize track name
              String trackName = _sanitizeTrackName(
                // meta.trackName ?? file.split('/').last,
                meta.trackName ?? file.split('/').last,
                isSingle,
              );
              // get album info from first song
              if (songs.isEmpty) {
                // album name
                album =
                    isSingle
                        ? listing.path.split("/").last
                        : _sanitizeAlbumName(
                          meta.albumName,
                          meta.albumArtistName,
                          folderName,
                        );
                // artist name
                artist = await _sanitizeArtistName(
                  album,
                  trackName,
                  meta.albumArtistName,
                  meta.albumName,
                  meta.trackArtistNames?.first,
                  isSingle,
                );
                if (isSingle) artist = _getSingleTrackArtist(trackName);
                // album art
                if (!isSingle) {
                  art = await ImageStoreService.getImageAsync<Uint8List>(
                    album,
                  );
                }
                if (art.isNull) {
                  art = await _prepareAlbumArtAsync(
                    cover,
                    meta.albumArt,
                    artist,
                    album,
                    isSingle,
                  );
                }
                // album year
                year = meta.year ?? year;
              }

              // track genre
              final String genre =
                  meta.genre ?? await _getTrackGenreAsync(trackName, artist);

              songs.add(
                Song(
                  id: songId,
                  path: file,
                  art: art!,
                  name: trackName,
                  artist: artist,
                  duration: meta.trackDuration ?? 0,
                  yearReleased: meta.year ?? DateTime.now().year,
                  genre: genre,
                  dateAdded: File(file).statSync().changed.toIso8601String(),
                  discNumber: meta.discNumber ?? 0,
                  mimeType: lookupMimeType(file) ?? 'Unknown',
                  bitRate: 0,
                ),
              );
              songId++;
            } on Exception catch (ex) {
              // A single unreadable/unsupported file (e.g. corrupt tags,
              // unsupported codec) should not abort mapping for the rest
              // of the library - log it, skip it, and keep going.
              skippedFileCount++;
              await Logger.logAsync(
                LogEvent<MusicService>(
                  severity: Severity.error,
                  tag: Tag.service,
                  line: 'Failed to map file "$file", skipping it: $ex',
                ),
              );
              continue;
            }
          }

          _albums.add(
            Album(
              id: albumId,
              art: songs.isNotEmpty ? songs.first.art : Uint8List(0),
              name: album,
              artist: songs.isNotEmpty ? songs.first.artist : 'Unknown',
              year: year,
              tracks: songs.length,
              songs: List.from(songs),
            ),
          );

          await Logger.logAsync(
            LogEvent<MusicService>(
              severity: Severity.information,
              tag: Tag.service,
              line: album,
            ),
          );

          // Save art to ImageStore
          if (art != null && art.isNotEmpty) {
            isSingle
                ? null
                : ImageStoreService().saveImageAsync<Uint8List>(album, art);
          }
        } on Exception catch (ex) {
          // Something went wrong processing this directory as a whole
          // (e.g. building album art or artist metadata) - skip this
          // directory rather than losing the rest of the library.
          skippedDirectoryCount++;
          await Logger.logAsync(
            LogEvent<MusicService>(
              severity: Severity.error,
              tag: Tag.service,
              line:
                  'Failed to map directory "${listing.path}", skipping it: '
                  '$ex',
            ),
          );
        } finally {
          // Clean up
          albumId++;
          cover = null;
          art = Uint8List(0);
          album = '';
          artist = 'Unknown';
          year = 0;
          songs.clear();
          isSingle = false;
        }
      }

      if (skippedFileCount > 0 || skippedDirectoryCount > 0) {
        await Logger.logAsync(
          LogEvent<MusicService>(
            severity: Severity.error,
            tag: Tag.service,
            line:
                'Album mapping finished with errors: '
                '$skippedFileCount file(s) and $skippedDirectoryCount '
                'director(y/ies) were skipped.',
          ),
        );
      }
    }
  }

  // ignore: unused_element
  Future<void> _mapOnlineAlbumsAsync() async {
    List<Album> onlineAlbums = await MediaStoreService().getAlbumsAsync();
    _albums.addAll(onlineAlbums);
  }

  Future<List<Artist>> getArtistsAsync(
    MapEntry<String?, SortOptionOrder> map,
  ) async {
    if (_artists.isEmpty) {
      await _mapArtistsAsync();
    }

    // Early return when no filter
    if (map.value == SortOptionOrder.none) return _artists;

    // Has filter
    List<Artist> sortedArtists = _artists.map((artist) => artist).toList();
    switch (map.key) {
      case 'Name':
        sortedArtists.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name),
        );
        break;
      case 'Albums':
        sortedArtists.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.albums.compareTo(b.albums)
                  : b.albums.compareTo(a.albums),
        );
        break;
      case 'Songs':
        sortedArtists.sort(
          (a, b) =>
              map.value == SortOptionOrder.asc
                  ? a.tracks.compareTo(b.tracks)
                  : b.tracks.compareTo(a.tracks),
        );
        break;
      default:
        sortedArtists = _artists;
        break;
    }

    return sortedArtists;
  }

  Future<void> _mapArtistsAsync() async {
    if (_albums.isEmpty) {
      await _mapAlbumsAsync();
    }

    int id = 0;
    int albums = 0;
    int tracks = 0;
    List<String> artists =
        _albums.map((album) => album.artist).toSet().toList();

    for (String artist in artists) {
      albums = _albums.where((album) => album.artist.equals(artist)).length;
      tracks = _albums
          .where((album) => album.artist.equals(artist))
          .map((album) => album.tracks)
          .reduce((first, second) => first + second);

      _artists.add(
        Artist(id: id, name: artist, albums: albums, tracks: tracks),
      );

      // clean up
      id++;
      albums = 0;
      tracks = 0;
    }
  }

  Future<List<T>> searchMusicLibraryAsync<T extends MediaCategory>({
    String? searchText,
  }) async {
    dynamic result = [];

    switch (T) {
      case Song:
        if (_songs.isEmpty) {
          await _mapSongsAsync();
        }

        _configureStrategy(SongSearchStrategy());
        result = await _searchProvider.searchMediaAsync(searchText, _songs);
        break;
      case Album:
        if (_albums.isEmpty) {
          await _mapAlbumsAsync();
        }
        _configureStrategy(AlbumSearchStrategy());
        result = await _searchProvider.searchMediaAsync(searchText, _albums);
        break;
      case Artist:
        if (_artists.isEmpty) {
          await _mapArtistsAsync();
        }
        _configureStrategy(ArtistSearchStrategy());
        result = await _searchProvider.searchMediaAsync(searchText, _artists);
        break;
      // case Folder:
      //   result = await _searchFolders();
      //   break;
      default:
      // log type mismatch
    }
    return result;
  }

  void _configureStrategy(SearchStrategy strategy) {
    _searchProvider.setStrategy = strategy;
  }

  bool _isFileImage(String file) {
    return file.contains(RegExp(r'.(jpeg|jpg|gif|png|bmp|webp|heic)$'));
  }

  bool _isFileAudio(String file) {
    return file.contains(RegExp(r'.(mp3|m4a|wav|wma|amr|ogg|flac)$'));
  }

  String _sanitizeTrackName(String trackName, bool isSingle) {
    String name = trackName;

    if (trackName.contains('SongsLover')) {
      name = trackName.split(' - ').first;
    } else if (trackName.contains('(Official Audio)') ||
        trackName.contains('(Official Video)')) {
      if (trackName.contains('-')) {
        name =
            isSingle
                ? trackName.split(' - ').last
                : trackName.split(' - ').first;
        name = name.split(' (Official Audio)').first;
        name = name.split(' (Official Video)').first;
      } else {
        name = trackName.split(' (Official Audio)').first;
        name = trackName.split(' (Official Video)').first;
      }
    } else if (trackName.contains(RegexLookup.Website) ||
        trackName.contains('www')) {
      if (trackName.contains('-')) {
        name = trackName.split(' - ').first;
      } else {
        name = trackName.split(' www').first;
      }
    } else if (_isFileAudio(trackName)) {
      name = trackName.split('.').first;
      if (name.contains('-')) name = name.split('-').last;
    }

    return name.trim();
  }

  String _sanitizeAlbumName(
    String? albumName,
    String? name,
    String alternativeName,
  ) {
    String album = 'Unknown';

    if (albumName.isNull && name.isNull) {
      return alternativeName;
    } else if (albumName.isNull) {
      return album;
    }

    if (albumName!.contains('Leakedzip.com')) {
      album = name.isNull ? albumName : name!;
    } else {
      album = albumName;
    }

    return album;
  }

  Future<String> _sanitizeArtistName(
    String album,
    String track,
    String? albumArtistName,
    String? albumName,
    String? trackArtist,
    bool isSingle,
  ) async {
    String artist = 'Unknown';

    if (albumArtistName.isNull) {
      if (isSingle) return 'Various Artists';
      artist = await MetaDataService().getTrackArtistAsync(album, track);
    } else if (albumName.isNull || albumName!.contains('Leakedzip.com')) {
      if (trackArtist.isNull) return albumArtistName!;
      artist = trackArtist!;
    } else {
      artist = albumArtistName!;
    }

    return artist;
  }

  Future<Uint8List> _convertFileToImageBytes(File file) async {
    List<int> imageBase64 = file.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List bytes = base64.decode(imageAsString);

    return bytes;
  }

  Future<Uint8List> _prepareAlbumArtAsync(
    String? file,
    Uint8List? albumArt,
    String artist,
    String album,
    bool isSingle,
  ) async {
    Uint8List? art = albumArt;

    if (isSingle) art = Uint8List(0);

    if (art.isNull) {
      if (file.isNull) {
        final String url = await MediaArtService().getAlbumArtAsync(
          artist,
          album,
          UserSettingsService.canDownloadArtistMedia,
        );
        if (url.isEmpty) {
          art = Uint8List(0);
        } else {
          art =
              albumArt ??
              (await NetworkAssetBundle(
                Uri.parse(url),
              ).load(url)).buffer.asUint8List();
        }
      } else {
        art = await _convertFileToImageBytes(File(file!));
      }
    }

    return art!;
  }

  String? _getCoverFromDirectory(DirectoryListing listing) {
    String? cover;

    final List<String> images =
        listing.files.where((file) => _isFileImage(file)).toList();
    if (images.isNotEmpty) {
      final List<String> covers =
          images.where((image) {
            final String fileWithExtension = image.split('/').last.trim();
            final String fileName = fileWithExtension.split('.').first.trim();
            return fileName.equals('cover');
          }).toList();
      cover = covers.isNotEmpty ? covers.first : images.first;
    }

    return cover;
  }

  String _getSingleTrackArtist(String? name) {
    String artist = 'Unknown';
    if (name.isNull) return artist;
    if (name!.contains('-')) artist = name.split('-').first.trim();

    return artist;
  }

  Future<String> _getTrackGenreAsync(String track, String artist) async {
    final String key = '${artist}__${track}__genre';
    String genre = 'Unknown';

    if (await _preferences.containsKey(key)) {
      try {
        genre = await _preferences.readAsync(key);
        // ignore: empty_catches
      } on Exception {}
    }

    return genre;
  }

  void _updateMappingResult(
    bool isBusy,
    String title,
    String message,
    String result,
    MessageSeverity severity,
  ) {
    _isMappingStreamController.sink.add(
      MappingResult(isBusy: isBusy, result: result),
    );
    MessageService().sendNotificationAsync(
      AppNotification(
        title: title,
        message: message,
        notificationText: result,
        severity: severity,
      ),
    );
  }

  Future _sendMappingNotificationAsync(
    String text,
    MessageSeverity severity,
  ) async {
    await MessageService().sendNotificationAsync(
      AppNotification(
        title: 'Mapping Update',
        message: '',
        notificationText: text,
        severity: severity,
      ),
      saveAsMessage: false,
    );
  }

  // ignore: unused_element
  Future<void> _saveMappingsToPreferences<T>() async {
    switch (T) {
      case Album:
        try {
          await _preferences.saveAsync(
            _MAPPED_ALBUMS_KEY,
            Album.encode(_albums),
          );
        } on Exception catch (ex) {
          await Logger.logAsync(
            LogEvent<MusicService>(
              severity: Severity.error,
              tag: Tag.service,
              line: ex.toString(),
            ),
          );
        }
        break;
      default:
    }
  }

  Future<void> _saveMappingsToStorage<T>() async {
    switch (T) {
      case Album:
        await FileStorageService.writeStringAsync<Album>(
          Album.encode(_albums),
          mode: FileMode.writeOnly,
        );
        break;
      default:
    }
  }

  Future<String?> _loadFromStorageAsync<T>() async {
    return await FileStorageService.readAsync<Album>();
  }

  String _getTimeAnalytics(int timeTaken) {
    if (timeTaken < 10000) {
      return 'completed in record time';
    } else if (timeTaken > 60000) {
      return 'took longer than expected';
    } else {
      return 'completed in the expected time';
    }
  }

  MessageSeverity _getTimeSeverity(int timeTaken) {
    if (timeTaken < 10000) {
      return MessageSeverity.information;
    } else if (timeTaken > 60000) {
      return MessageSeverity.alert;
    } else {
      return MessageSeverity.information;
    }
  }

  String? getAlbumName(String name) {
    String? album;
    try {
      for (final Album albumRecord in _albums) {
        if (albumRecord.songs
            .where((song) => song.name.equals(name))
            .isNotEmpty) {
          album = albumRecord.name;
          break;
        }
      }
      if (album.isNull) throw Exception();
    } on Exception {
      Logger.logAsync(
        LogEvent<MusicService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Could not find album name for song $name',
        ),
      );
    }

    return album;
  }

  Song getSongByPath(String path) =>
      _songs.firstWhere((song) => song.path.equals(path));
}
