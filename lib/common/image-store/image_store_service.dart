import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:boombox/common/image-store/image_store_item_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/player-component/models/cached_album_art_model.dart';

class ImageStoreService {
  // ignore: unused_field
  late List<ImageStoreItem> _items;

  static final ImageStoreService _instance = ImageStoreService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory ImageStoreService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  ImageStoreService._internal() {
    _init();
  }

  Future<void> _init() async {
    _items = [];
  }

  static getImageAsync<T>(String identifier) async {
    identifier = _sanitizeKey(identifier);
    if (!await FileStorageService.fileInstanceExistsAsync(
      key: identifier,
    )) return null;

    String? contents = await FileStorageService.readAsync(key: identifier);
    if (contents.isNull) return null;
    ImageStoreItem storeItem = ImageStoreItem.decode(contents!);

    switch (T) {
      case Uint8List:
        return convert.base64Decode(storeItem.value);
      case String:
        return storeItem.value;
      default:
        Logger.logAsync(
          LogEvent<ImageStoreService>(
            severity: Severity.warning,
            tag: Tag.service,
            line: 'Image type not defined.',
          ),
        );
        return null;
    }
  }

  Future<void> saveImageAsync<T>(
    String identifier,
    T image,
  ) async {
    identifier = _sanitizeKey(identifier);
    if (await FileStorageService.fileInstanceExistsAsync(key: identifier)) {
      return;
    }

    String imgString;
    switch (T) {
      case Uint8List:
        imgString = convert.base64Encode(image as Uint8List);
        break;
      case String:
        imgString = image as String;
        break;
      default:
        Logger.logAsync(
          LogEvent<ImageStoreService>(
            severity: Severity.warning,
            tag: Tag.service,
            line: 'Image type not defined.',
          ),
        );
        return;
    }

    await FileStorageService.writeStringAsync<ImageStoreItem>(
      ImageStoreItem.encode(
        ImageStoreItem(
          identifier: identifier,
          value: imgString,
        ),
      ),
      key: identifier,
    );
  }

  static Future<String?> cacheAlbumArtAsync(String name, Uint8List image) async {
    return await FileStorageService.writeImageAsync<CachedAlbumArt>(
      CachedAlbumArt(
        key: _sanitizeKey(name),
        imageBytes: image,
      ),
    );
  }

  static Future<String?> getCachedAlbumArtAsync(String name) async {
    return (await FileStorageService.readImageAsync<CachedAlbumArt>(
      _sanitizeKey(name),
    ))
        ?.path;
  }

  static String _sanitizeKey(String key) {
    RegExp re = RegExp('[^A-Za-z0-9]');
    String sanitizedKey = key;
    for (final Match match in re.allMatches(sanitizedKey)) {
      final String char = key[match.end - 1];
      sanitizedKey = char.equals(' ')
          ? sanitizedKey.replaceFirst(char, '_')
          : sanitizedKey.replaceFirst(char, '');
    }

    return sanitizedKey;
  }
}
