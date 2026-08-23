import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/playlist-component/models/search_result_model.dart';

class AlbumSearchResult {
  final Album album;
  List<SearchResult<Song>> songs;

  AlbumSearchResult({
    required this.album,
    required this.songs,
  });
}
