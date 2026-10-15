/// The physical storage location the app should prefer for its own data
/// (Eternal Storage) and for labelling media directories the user has added.
///
/// Older devices (e.g. the Huawei Y7 2018 this app was originally built
/// against) relied on an SD card being present. Newer devices (e.g. the
/// Samsung A23) may not have removable storage at all, so this can no
/// longer be assumed - it must be detected or explicitly chosen.
enum StorageSource {
  /// Prefer an SD card when one is present, otherwise fall back to the
  /// device's internal (primary) shared storage. This is the default and
  /// works correctly on devices with or without an SD card.
  automatic,

  /// Always use the device's internal (primary) shared storage, even if an
  /// SD card is present.
  internal,

  /// Always use the SD card. If no SD card is present this falls back to
  /// internal storage rather than failing.
  sdCard,
}

extension StorageSourceDisplay on StorageSource {
  String get displayName {
    switch (this) {
      case StorageSource.automatic:
        return 'Automatic';
      case StorageSource.internal:
        return 'Internal Storage';
      case StorageSource.sdCard:
        return 'SD Card';
    }
  }
}
