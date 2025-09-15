import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/http/services/http_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:http/http.dart';
import 'dart:convert' as convert;

class MetaDataService {
  late SharedPreferencesService _preferences;
  late Client _client;

  final String _DISCOGS_SEARCH_URL =
      'https://api.discogs.com/database/search?q=';
  final String _DISCOGS_AUTH_TOKEN =
      '&token=EMXaRCBhwflWCpbCLvAkVtPsoAHLtyULtzwYLgwA';

  static final MetaDataService _instance = MetaDataService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory MetaDataService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  MetaDataService._internal() {
    _init();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _client = HttpService().client;
  }

  Future<String> getTrackGenreAsync(String name, String artist) async {
    final String key = '${artist}__${name}__genre';
    String genre = 'Unknown';

    // Invalid search params
    if (name.isEmpty || artist.isEmpty) return genre;

    try {
      genre = await _preferences.readAsync(key);
    } on Exception {
      try {
        Response response = await _client.get(
          Uri.parse(
            '$_DISCOGS_SEARCH_URL$name $artist'
            '$_DISCOGS_AUTH_TOKEN',
          ),
        );
        Map<String, dynamic> json = convert.json.decode(response.body);
        List results = json['results'] as List;
        if (results.length > 1) {
          Map<String, dynamic> map =
              results.elementAt(1) as Map<String, dynamic>;
          List lsGenre = map.containsKey('genre') ? map['genre'] as List : [];
          if (lsGenre.isNotEmpty) {
            genre = lsGenre.first;
            Logger.logAsync(
              LogEvent<MetaDataService>(
                severity: Severity.information,
                tag: Tag.service,
                line: 'Found genre for $key: $genre',
              ),
            );
          }
        }
      } on Exception catch (ex) {
        Logger.logAsync(
          LogEvent<MetaDataService>(
            severity: Severity.error,
            tag: Tag.service,
            line: ex.toString(),
          ),
        );
      } finally {
        if (!genre.equals('Unknown') && !await _preferences.containsKey(key)) {
          await _saveToPreferences(key, genre, line: 'Unable to save genre.');
        }
      }
    }

    return genre;
  }

  Future<String> getTrackArtistAsync(String album, String track) async {
    final String key = '${album}__${track}__artist';
    String artist = 'Unknown';

    // Invalid search params
    if (track.isEmpty) return artist;

    try {
      artist = await _preferences.readAsync(key);
    } on Exception {
      try {
        Response response = await _client.get(
          Uri.parse(
            '$_DISCOGS_SEARCH_URL$album $track'
            '$_DISCOGS_AUTH_TOKEN',
          ),
        );
        Map<String, dynamic> json = convert.json.decode(response.body);
        List results = json['results'] as List;
        if (results.length > 1) {
          Map<String, dynamic> map =
              results.elementAt(1) as Map<String, dynamic>;
          String resourceUri =
              map.containsKey('resource_url') ? map['resource_url'] : '';
          try {
            Response response = await _client.get(
              Uri.parse(resourceUri),
            );
            Map<String, dynamic> json = convert.json.decode(response.body);
            List artists = json.containsKey('artists') ? json['artists'] : [];
            artist = artists.first['name'];
            Logger.logAsync(
              LogEvent<MetaDataService>(
                severity: Severity.information,
                tag: Tag.service,
                line: 'Found artist for $key: $artist',
              ),
            );
          } on Exception catch (ex) {
            Logger.logAsync(
              LogEvent<MetaDataService>(
                severity: Severity.information,
                tag: Tag.service,
                line: ex.toString(),
              ),
            );
          }
        }
      } on Exception catch (ex) {
        Logger.logAsync(
          LogEvent<MetaDataService>(
            severity: Severity.error,
            tag: Tag.service,
            line: ex.toString(),
          ),
        );
      }
    } finally {
      if (!artist.equals('Unknown') && !await _preferences.containsKey(key)) {
        await _saveToPreferences(key, artist, line: 'Unable to save artist.');
      }
    }

    return artist;
  }

  Future<String> getArtistBio(String artist) async {
    final String key = '${artist}__bio';
    String bio = 'Bio not found';

    // Invalid search params
    if (artist.isEmpty) return bio;

    try {
      bio = await _preferences.readAsync(key);
    } on Exception {
      try {
        Response response = await _client.get(
          Uri.parse(
            '$_DISCOGS_SEARCH_URL$artist'
            '$_DISCOGS_AUTH_TOKEN',
          ),
        );
        Map<String, dynamic> json = convert.json.decode(response.body);
        List results = json['results'] as List;
        if (results.isNotEmpty) {
          Map<String, dynamic> map = results.first as Map<String, dynamic>;
          String resourceUri =
              map.containsKey('resource_url') ? map['resource_url'] : '';
          try {
            Response response = await _client.get(
              Uri.parse(resourceUri),
            );
            Map<String, dynamic> json = convert.json.decode(response.body);
            if (json.containsKey('profile')) bio = json['profile'];
            bio.trim();
            Logger.logAsync(
              LogEvent<MetaDataService>(
                severity: Severity.information,
                tag: Tag.service,
                line: 'Found bio for $key: $artist',
              ),
            );
          } on Exception catch (ex) {
            Logger.logAsync(
              LogEvent<MetaDataService>(
                severity: Severity.information,
                tag: Tag.service,
                line: ex.toString(),
              ),
            );
          }
        }
      } on Exception catch (ex) {
        Logger.logAsync(
          LogEvent<MetaDataService>(
            severity: Severity.information,
            tag: Tag.service,
            line: ex.toString(),
          ),
        );
      }
    } finally {
      if (!bio.equals('Bio not found') &&
          !await _preferences.containsKey(key)) {
        await _saveToPreferences(key, artist,
            line: 'Unable to bio for $artist.');
      }
    }

    return bio;
  }

  Future<void> _saveToPreferences(
    String key,
    String value, {
    String? line,
  }) async {
    try {
      await _preferences.saveAsync(key, value);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<MetaDataService>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }
}
