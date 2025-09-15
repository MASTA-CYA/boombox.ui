import 'dart:typed_data';

import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'dart:convert' as convert;

class Playlist {
  final int id;
  final String date;
  final Uint8List? image;
  final String name;
  int tracks;
  final List<PlaylistSong> songs;

  Playlist({
    required this.id,
    required this.date,
    this.image,
    required this.name,
    required this.tracks,
    required this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        date: json['date'],
        image: json['image'],
        name: json['name'],
        tracks: json['tracks'],
        songs: (convert.json.decode(json['songs']) as List)
            .map((e) => e as PlaylistSong)
            .toList(),
      );

  static Map<String, dynamic> toJson(Playlist playlist) => {
        'id': playlist.id,
        'date': playlist.date,
        'image': playlist.image,
        'name': playlist.name,
        'tracks': playlist.tracks,
        'songs': convert.json.encode(playlist.songs),
      };

  static String encode(List<Playlist> playlists) => convert.json.encode(
        playlists
            .map<Map<String, dynamic>>((playlist) => Playlist.toJson(playlist))
            .toList(),
      );

  static List<Playlist> decode(String jsonString) =>
      (convert.json.decode(jsonString) as List<dynamic>)
          .map<Playlist>((playlist) => Playlist.fromJson(playlist))
          .toList();
}
