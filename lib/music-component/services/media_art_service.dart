import 'dart:math';

import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/http/services/http_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:http/http.dart';
import 'dart:convert' as convert;

class MediaArtService {
  late SharedPreferencesService _preferences;
  late Client _client;

  static const String _API_KEY = 'AIzaSyB80DI0uHxbwiSAXMewJZTv5PLx_hG_35I';
  static const String _CX_KEY = '65350ea0187534cb6';

  final String _GOOGLE_SEARCH_ENGINE_URL =
      'https://www.googleapis.com/customsearch/v1?key=$_API_KEY&cx=$_CX_KEY&searchType=image&q=';

  static final MediaArtService _instance = MediaArtService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory MediaArtService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  MediaArtService._internal() {
    _init();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _client = HttpService().client;
  }

  Future<String> getArtistArtAsync(
    String artist,
    bool canDownload,
  ) async {
    final String key = '${artist}__images';
    List<String> images = [''];

    // Do not download media
    if (!canDownload) return images.first;

    // Invalid search params
    if (artist.isEmpty) return images.first;

    // Check if images have previously been saved
    try {
      images =
          (convert.json.decode(await _preferences.readAsync(key)) as List<dynamic>)
              .cast<String>();
    } on Exception {
      try {
        // Search the web
        Response response = await _client.get(
          Uri.parse('$_GOOGLE_SEARCH_ENGINE_URL$artist'),
        );
        Map<String, dynamic> json = convert.json.decode(response.body);
        images = (json['items'] as List)
            .map((result) => result['link'] as String)
            .toList()
            .map((link) => link.endsWith('png') ||
                    link.endsWith('jpg') ||
                    link.endsWith('jpeg')
                ? link
                : '')
            .toList()
            .where((link) => link.isNotEmpty)
            .toList();
      } on Exception catch (ex) {
        await Logger.logAsync(
          LogEvent<MediaArtService>(
            severity: Severity.error,
            tag: Tag.service,
            line: ex.toString(),
          ),
        );
      } finally {
        if (!await _preferences.containsKey(key)) {
          _saveMediaAsync(key, images);
        }
      }
    }

    return images.elementAt(Random().nextInt(images.length));
  }

  Future<String> getAlbumArtAsync(
    String artist,
    String album,
    bool canDownload,
  ) async {
    final String key = '${artist}_${album}__images';
    List<String> images = [''];

    // Do not download media
    if (!canDownload) return images.first;

    // Invalid search params
    if (artist.isEmpty || album.isEmpty) return images.first;

    // Check if images have previously been saved
    try {
      images =
          (convert.json.decode(await _preferences.readAsync(key)) as List<dynamic>)
              .cast<String>();
    } on Exception {
      try {
        // Search the web
        Response response = await _client.get(
          Uri.parse('$_GOOGLE_SEARCH_ENGINE_URL$artist $album'),
        );
        Map<String, dynamic> json = convert.json.decode(response.body);
        images = (json['items'] as List)
            .map((result) => result['link'] as String)
            .toList()
            .map((link) => link.endsWith('png') ||
                    link.endsWith('jpg') ||
                    link.endsWith('jpeg')
                ? link
                : '')
            .toList()
            .where((link) => link.isNotEmpty)
            .toList();
      } on Exception catch (ex) {
        await Logger.logAsync(
          LogEvent<MediaArtService>(
            severity: Severity.error,
            tag: Tag.service,
            line: ex.toString(),
          ),
        );
      } finally {
        if (!await _preferences.containsKey(key)) {
          _saveMediaAsync(key, images);
        }
      }
    }

    return images.elementAt(Random().nextInt(images.length));
  }

  Future<void> _saveMediaAsync(String key, List<String> images) async {
    try {
      await _preferences.saveAsync(key, convert.json.encode(images));
    } on Exception {
      await Logger.logAsync(
        LogEvent<MediaArtService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Unable to save media locally.',
        ),
      );
    }
  }
}
