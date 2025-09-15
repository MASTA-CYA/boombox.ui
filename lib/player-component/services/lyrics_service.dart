import 'dart:async';

import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/http/services/http_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:http/http.dart';
import 'dart:convert' as convert;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';

class LyricsService {
  late SharedPreferencesService _preferences;
  late Client _client;

  final String SEARCH_SONG_URL = 'https://genius.com/api/search/multi?q=';

  static final LyricsService _instance = LyricsService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory LyricsService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  LyricsService._internal() {
    _init();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _client = HttpService().client;
  }

  Future<String> getTrackLyricsAsync(
    String title,
    String artist, {
    bool canSave = false,
  }) async {
    final String key = '${artist}__$title';
    String lyrics = '';

    // Invalid search params
    if (title.isEmpty || artist.isEmpty) return lyrics;

    // Check if lyrics have previously been saved
    try {
      lyrics = await _preferences.readAsync(key);
    } on Exception {
      // Search Song
      try {
        Response searchResponse = await _client.get(
          Uri.parse('$SEARCH_SONG_URL$title $artist'),
        );
        Map<String, dynamic> json = convert.json.decode(searchResponse.body);

        // Search lyrics
        String lyricsUrl = (json['response']['sections'][0]['hits']
            as List<dynamic>)[0]['result']['url'];
        Response lyricsResponse = await _client.get(Uri.parse(lyricsUrl));
        lyrics = await _scrapeLyricsAsync(lyricsResponse.body);
      } on Exception catch (ex) {
        await Logger.logAsync(
          LogEvent<LyricsService>(
            severity: Severity.error,
            tag: Tag.service,
            line: ex.toString(),
          ),
        );
      } finally {
        if (canSave && !(await _preferences.containsKey(key))) {
          _saveLyricsAsync(key, lyrics);
        }
      }
    }

    return lyrics;
  }

  Future<String> _scrapeLyricsAsync(String html) async {
    BeautifulSoup bs = BeautifulSoup(html.replaceAll('<br/>', '\n'));

    final String excludedHeader = bs
            .find("div", class_: "LyricsHeader__Container-ejidji-1 hbjTyd")
            ?.getText()
            .trim() ??
        '';
    final String excludedFooter = bs
            .find("div", class_: "LyricsFooter__Container-iqbcge-0 gBtUIQ")
            ?.getText()
            .trim() ??
        '';

    return (bs.find("div", class_: "Lyrics__Root")?.getText().trim() ??
                bs.find("div", class_: "lyrics")?.getText().trim())
            ?.replaceAll(RegExp('You might also like[0-9]+Embed'), '')
            .replaceAll(excludedHeader, '')
            .replaceAll(excludedFooter, '') ??
        '';
  }

  Future<void> _saveLyricsAsync(String key, String lyrics) async {
    try {
      await _preferences.saveAsync(key, lyrics);
    } on Exception {
      await Logger.logAsync(
        LogEvent<LyricsService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Unable to save lyrics locally.',
        ),
      );
    }
  }
}
