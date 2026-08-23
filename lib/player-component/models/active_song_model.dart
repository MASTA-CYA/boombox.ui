import 'dart:typed_data';

class ActiveSong {
  final Uint8List art;
  final String name;
  final String artist;

  ActiveSong({
    required this.art,
    required this.name,
    required this.artist,
  });
}
