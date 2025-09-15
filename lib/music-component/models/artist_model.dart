import 'package:boombox/music-component/models/media_category_interface.dart';

class Artist implements MediaCategory{
  final int id;
  final String name;
  final int albums;
  final int tracks;

  Artist({
    required this.id,
    required this.name,
    required this.albums,
    required this.tracks,
  });
}
