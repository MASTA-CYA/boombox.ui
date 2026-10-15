import 'dart:io';

import 'package:boombox/settings-component/models/enums/storage_source_enum.dart';
import 'package:path_provider/path_provider.dart';

/// Resolves which physical storage volume (internal vs. SD card) the app
/// should use, without assuming a specific device or a specific SD card is
/// present.
///
/// On Android, `getExternalStorageDirectories()` always returns the
/// device's primary (internal) shared storage as its first entry. Any
/// additional entries are removable volumes - typically an SD card, but
/// this stays generic rather than matching hardcoded volume IDs, so it
/// keeps working across devices (and across SD cards) without edits.
class StorageDetectionService {
  static Future<List<Directory>> _getExternalDirectoriesAsync() async {
    try {
      return await getExternalStorageDirectories() ?? [];
    } on Exception {
      return [];
    }
  }

  /// The device's primary (internal) shared storage directory, if available.
  static Future<Directory?> getInternalStorageDirectoryAsync() async {
    final List<Directory> dirs = await _getExternalDirectoriesAsync();
    return dirs.isNotEmpty ? dirs.first : null;
  }

  /// The first removable storage volume (SD card), if one is present.
  static Future<Directory?> getSdCardDirectoryAsync() async {
    final List<Directory> dirs = await _getExternalDirectoriesAsync();
    return dirs.length > 1 ? dirs[1] : null;
  }

  /// Whether the device currently has an SD card (or other removable
  /// storage volume) available.
  static Future<bool> hasSdCardAsync() async =>
      (await getSdCardDirectoryAsync()) != null;

  /// Resolves which directory to use for a given storage [preference].
  ///
  /// Always falls back to whatever storage is actually available rather
  /// than throwing - e.g. [StorageSource.sdCard] on a device with no SD
  /// card falls back to internal storage instead of failing.
  static Future<Directory?> resolveStorageDirectoryAsync(
    StorageSource preference,
  ) async {
    final Directory? sdCard = await getSdCardDirectoryAsync();
    final Directory? internal = await getInternalStorageDirectoryAsync();

    switch (preference) {
      case StorageSource.internal:
        return internal ?? sdCard;
      case StorageSource.sdCard:
        return sdCard ?? internal;
      case StorageSource.automatic:
        return sdCard ?? internal;
    }
  }

  /// True if [path] lives under the device's current SD card volume.
  static Future<bool> isPathOnSdCardAsync(String path) async {
    final Directory? sdCard = await getSdCardDirectoryAsync();
    if (sdCard == null) return false;

    return path.startsWith(volumeRootOf(sdCard.path));
  }

  /// Reduces a nested external-storage path
  /// (e.g. `/storage/9016-4EF8/Android/data/<package>/files`) down to its
  /// volume root (`/storage/9016-4EF8`).
  static String volumeRootOf(String path) {
    final List<String> parts = path.split('/');
    return parts.length > 2 ? '/${parts[1]}/${parts[2]}' : path;
  }
}
