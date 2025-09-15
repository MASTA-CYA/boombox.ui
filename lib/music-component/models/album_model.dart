import 'dart:typed_data';
import 'dart:convert' as convert;

import 'package:boombox/common/image-store/image_store_service.dart';
import 'package:boombox/music-component/models/media_category_interface.dart';
import 'package:boombox/music-component/models/song_model.dart';

class Album implements MediaCategory {
  final int id;
  final Uint8List art;
  final String name;
  final String artist;
  final int year;
  final List<Song> songs;
  final int tracks;

  Album({
    required this.id,
    required this.art,
    required this.name,
    required this.artist,
    required this.year,
    required this.songs,
    required this.tracks,
  });

  static Future<Album> fromJson(Map<String, dynamic> json) async {
    Uint8List art =
        (await ImageStoreService.getImageAsync<Uint8List>(json['name'])) ?? Uint8List(0);
    return Album(
      id: int.parse(json['id']),
      art: art,
      name: json['name'],
      artist: json['artist'],
      year: int.parse(json['year']),
      songs: Song.decode(json['songs'], art),
      tracks: int.parse(json['tracks']),
    );
  }

  static Map<String, dynamic> toJson(Album album) => {
        'id': album.id.toString(),
        'art': Uint8List(0),
        'name': album.name,
        'artist': album.artist,
        'year': album.year.toString(),
        'songs': Song.encode(album.songs),
        'tracks': album.tracks.toString(),
      };

  static String encode(List<Album> albums) => convert.json.encode(
        List<Map<String, dynamic>>.unmodifiable(
          albums.map<Map<String, dynamic>>((album) => Album.toJson(album)),
        ),
      );

  static Future<List<Album>> decode(String jsonString) async {
    List<Album> albums = [];
    for (var album in (convert.json.decode(jsonString) as List<dynamic>)) {
      albums.add(await Album.fromJson(album));
    }

    return albums;
  }
}
