import 'dart:async';
import 'dart:io';

import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/directory-component/models/directory_listing_model.dart';
import 'package:boombox/directory-component/models/directory_parent_model.dart';
import 'package:boombox/message-component/models/message_severity_enum.dart';
import 'package:boombox/message-component/models/notification_model.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:flutter/material.dart';

class DirectoryService with ChangeNotifier {
  static const String _MEDIA_DIRECTORIES_PARENT_KEY = 'DIRECTORIES_PARENT';
  static const String _MEDIA_DIRECTORIES_LISTING_KEY = 'DIRECTORIES_LISTING';

  late SharedPreferencesService _preferences;
  late List<DirectoryParent> _directories;
  late List<DirectoryListing> _mappedListing;

  // late StreamController<bool> _remapController;

  // Stream<bool> get _remapStream => _remapController.stream;

  static final DirectoryService _instance = DirectoryService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory DirectoryService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  DirectoryService._internal() {
    _init();
  }

  void _init() async {
    _preferences = SharedPreferencesService();
    _directories = [];
    _mappedListing = [];

    // _remapController = StreamController.broadcast();
  }

  Future<void> _getDirectoryListingAsync() async {
    try {
      _directories = DirectoryParent.decode(
        await _preferences.readAsync(_MEDIA_DIRECTORIES_PARENT_KEY),
      );
    } on Exception catch (ex) {
      // Attempt to use Eternal storage
      String? result = await FileStorageService.readAsync<DirectoryParent>();
      if (!result.isNull) {
        _directories = DirectoryParent.decode(result!);
      }

      await Logger.logAsync(
        LogEvent<DirectoryService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    } finally {}
  }

  /// Maps each added directory's display name to its full [DirectoryParent],
  /// so callers (e.g. the directory listing UI) can inspect the folder
  /// count as well as the real path - needed to tell whether a directory
  /// actually lives on an SD card or on internal storage.
  Future<Map<String, DirectoryParent>> getDirectoryListingAsync() async {
    if (_directories.isEmpty) {
      await _getDirectoryListingAsync();
    }

    Map<String, DirectoryParent> listing = {};
    for (DirectoryParent directory in _directories) {
      listing.addAll({directory.displayName: directory});
    }

    return listing;
  }

  Future<bool> hasDirectoryListingAsync() async {
    if (_directories.isEmpty) {
      await _getDirectoryListingAsync();
    }

    return _directories.isNotEmpty;
  }

  Future<void> addDirectoriesAsync(String directory) async {
    String path = '';
    List<String> files = [];
    List<DirectoryListing> listing = [];

    await for (FileSystemEntity folder in Directory(directory).list(
      recursive: false,
      followLinks: false,
    )) {
      if (folder is Directory) {
        path = folder.path;
        await Logger.logAsync(
          LogEvent<DirectoryService>(
            severity: Severity.information,
            tag: Tag.service,
            line: 'Directory: ${folder.path}',
          ),
        );

        await for (FileSystemEntity file in Directory(folder.path).list(
          recursive: false,
          followLinks: false,
        )) {
          files.add(file.path);
          await Logger.logAsync(
            LogEvent<DirectoryService>(
              severity: Severity.information,
              tag: Tag.service,
              line: 'File: ${file.path}',
            ),
          );
          debugPrint('File: ${file.path}');
        }
        listing.add(DirectoryListing(path: path, files: List.from(files)));
        files.clear();
      }
    }
    _directories.add(
      DirectoryParent(
        path: directory,
        folders: List.from(listing),
        displayName: directory.split("/").last.trim(),
      ),
    );
    await _preferences.saveAsync(
      _MEDIA_DIRECTORIES_PARENT_KEY,
      DirectoryParent.encode(_directories),
    );
    listing.clear();

    List<DirectoryListing> mappedListing = [];
    for (List<DirectoryListing> folders in _directories.map((e) => e.folders)) {
      mappedListing.addAll(folders);
    }
    _mappedListing = mappedListing;
    await _preferences.saveAsync(
      _MEDIA_DIRECTORIES_LISTING_KEY,
      DirectoryListing.encode(mappedListing),
    );
    await _saveToStorage();
    await _invalidateAlbumMappingCacheAsync();

    notifyListeners();
    await _sendNotificationAsync();
  }

  Future removeDirectoryAsync({String? displayName}) async {
    try {
      displayName.isNull
          ? _directories.clear()
          : _directories.removeWhere(
              (element) => element.displayName == displayName,
            );
      await _preferences.saveAsync(
        _MEDIA_DIRECTORIES_PARENT_KEY,
        DirectoryParent.encode(_directories),
      );
      await _saveToStorage();
      await _invalidateAlbumMappingCacheAsync();
      notifyListeners();
      await _sendNotificationAsync();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<DirectoryService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> syncDirectoriesAsync() async {
    // Note: addDirectoriesAsync() invalidates the album mapping cache on
    // every call, so re-adding each directory below already forces
    // MusicService to rescan afterwards - no separate invalidation needed
    // here.
    final List<String> paths = _directories.map((e) => e.path).toList();
    _directories.clear();
    for (String path in paths) {
      await addDirectoriesAsync(path);
    }

    await _sendNotificationAsync();
  }

  /// Invalidates the persisted album mapping cache so [MusicService] is
  /// forced to perform a fresh filesystem scan the next time the library is
  /// requested, instead of silently reusing a stale (or even empty) cached
  /// mapping that no longer reflects the current directory listing.
  Future<void> _invalidateAlbumMappingCacheAsync() async {
    await FileStorageService.removeAsync<Album>();
    await Logger.logAsync(
      LogEvent<DirectoryService>(
        severity: Severity.information,
        tag: Tag.service,
        line:
            'Album mapping cache invalidated after directory change; '
            'MusicService will rescan on next request.',
      ),
    );
  }

  Future<void> _saveToStorage() async {
    await FileStorageService.writeStringAsync<DirectoryParent>(
      DirectoryParent.encode(_directories),
      mode: FileMode.writeOnly,
    );
    await FileStorageService.writeStringAsync<DirectoryListing>(
      DirectoryListing.encode(_mappedListing),
      mode: FileMode.writeOnly,
    );
  }

  Future<void> _sendNotificationAsync() async {
    await MessageService().sendNotificationAsync(
      AppNotification(
        title: 'Media Library Mapping',
        message:
            'Directory listing has changed and media library needs to be remapped.',
        notificationText: 'Media mapping started',
        severity: MessageSeverity.information,
      ),
    );
  }
}
