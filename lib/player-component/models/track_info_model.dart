import 'dart:typed_data';

class TrackInfo {
  final Uint8List? art;
  final String? path;
  final String? title;
  final String? artist;
  final String? details;
  final int? year;
  final String? genre;
  final String? dateAdded;
  final int? discNumber;
  final String? mimeType;
  final int? bitRate;
  final int? duration;

  TrackInfo({
    this.art,
    this.path,
    this.title,
    this.artist,
    this.details,
    this.year,
    this.genre,
    this.dateAdded,
    this.discNumber,
    this.mimeType,
    this.bitRate,
    this.duration,
  });
}
