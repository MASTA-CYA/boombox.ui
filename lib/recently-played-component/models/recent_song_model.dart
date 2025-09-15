import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:boombox/common/image-store/image_store_service.dart';
import 'package:boombox/music-component/music_barrel.dart';

class RecentSong {
  final String album;
  final Song song;
  final String time;

  RecentSong({
    required this.album,
    required this.song,
    required this.time,
  });

  static Future<RecentSong> fromJson(Map<String, dynamic> json) async {
    final String album = MusicService().getAlbumName(
          json['song']['name'],
        ) ??
        'Unknown';
    Uint8List art = await ImageStoreService.getImageAsync<Uint8List>(
          album,
        ) ??
        Uint8List(0);
    return RecentSong(
      album: json['album'],
      song: Song.fromJson(json['song'], art: art),
      time: json['time'],
    );
  }

  static Map<String, dynamic> toJson(RecentSong recent) => {
        'album': recent.album,
        'song': Song.toJson(recent.song),
        'time': recent.time,
      };

  static String encode(List<RecentSong> songs) => convert.json.encode(
        songs
            .map<Map<String, dynamic>>((song) => RecentSong.toJson(song))
            .toList(),
      );

  static Future<List<RecentSong>> decode(String jsonString) async {
    List<RecentSong> songs = [];
    for (var song in convert.json.decode(jsonString) as List<dynamic>) {
      songs.add(await RecentSong.fromJson(song));
    }

    return songs;
  }
}
