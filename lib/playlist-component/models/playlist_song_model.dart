import 'package:boombox/music-component/models/song_model.dart';
import 'dart:convert' as convert;

class PlaylistSong {
  final Song song;
  final bool isPlaying;

  PlaylistSong({
    required this.song,
    this.isPlaying = false,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) => PlaylistSong(
        song: convert.json.decode(json['song']),
        isPlaying: json['isPlaying'],
      );

  static Map<String, dynamic> toJson(PlaylistSong song) => {
        'song': song.song,
        'isPlaying': convert.json.encode(song.isPlaying),
      };
}
