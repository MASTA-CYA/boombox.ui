import 'dart:typed_data';
import 'dart:convert' as convert;

import 'package:boombox/music-component/models/media_category_interface.dart';

class Song implements MediaCategory {
  final int id;
  final String path;
  final Uint8List art;
  final String name;
  final String artist;
  final int duration;
  final int yearReleased;
  final String genre;
  final String dateAdded;
  final int discNumber;
  final String mimeType;
  final int bitRate;

  Song({
    required this.id,
    required this.path,
    required this.art,
    required this.name,
    required this.artist,
    required this.duration,
    required this.yearReleased,
    required this.genre,
    required this.dateAdded,
    required this.discNumber,
    required this.mimeType,
    required this.bitRate,
  });

  static fromJson(Map<String, dynamic> json, {Uint8List? art}) => Song(
        id: json['id'],
        path: json['path'],
        art: art ?? Uint8List(0),
        name: json['name'],
        artist: json['artist'],
        duration: json['length'],
        yearReleased: json['year'],
        genre: json['genre'],
        dateAdded: json['dateAdded'],
        discNumber: int.parse(json['discNumber']),
        mimeType: json['mimeType'],
        bitRate: int.parse(json['bitRate']),
      );

  static Map<String, dynamic> toJson(Song song) => {
        'id': song.id,
        'path': song.path,
        'art': Uint8List(0),
        'name': song.name,
        'artist': song.artist,
        'length': song.duration,
        'year': song.yearReleased,
        'genre': song.genre,
        'dateAdded': song.dateAdded,
        'discNumber': song.discNumber.toString(),
        'mimeType': song.mimeType,
        'bitRate': song.bitRate.toString(),
      };

  static String encode(List<Song> songs) => convert.json.encode(
        List<Map<String, dynamic>>.unmodifiable(
          songs.map<Map<String, dynamic>>((song) => Song.toJson(song)),
        ),
      );

  static List<Song> decode(String jsonString, Uint8List art) =>
      (convert.json.decode(jsonString) as List<dynamic>)
          .map<Song>((song) => Song.fromJson(song, art: art))
          .toList();
}
