import 'dart:typed_data';

class CachedAlbumArt {
  final String key;
  final Uint8List imageBytes;

  const CachedAlbumArt({
    required this.key,
    required this.imageBytes,
  });
}
