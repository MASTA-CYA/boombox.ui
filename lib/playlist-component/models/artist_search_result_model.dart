import 'package:boombox/playlist-component/models/album_search_result_model.dart';
import 'package:boombox/playlist-component/models/search_result_model.dart';

class ArtistSearchResult {
  final String artist;
  final List<SearchResult<AlbumSearchResult>> albums;

  ArtistSearchResult({
    required this.artist,
    required this.albums,
  });
}
