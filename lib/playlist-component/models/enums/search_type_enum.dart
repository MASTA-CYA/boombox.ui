import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/models/song_model.dart';

enum SearchType {
  song,
  album,
  artist;
  // folder,

  factory SearchType.fromMediaCategory(dynamic category) {
    switch (category) {
      case Song:
        return SearchType.song;
      case Album:
        return SearchType.album;
      case Artist:
        return SearchType.artist;
      default:
        return SearchType.song;
    }
  }
}

extension SearchTypeExtension on SearchType {
  String get icon => _getIcon();
  dynamic get mediaCategory => _getMediaCategory();

  String _getIcon() {
    String icon = '';

    switch (this) {
      case SearchType.song:
        icon = 'cd';
        break;
      case SearchType.album:
        icon = 'album';
        break;
      case SearchType.artist:
        icon = 'artist';
        break;
      // case SearchType.folder:
      //   icon = 'folder';
      //   break;
    }

    return icon;
  }

  dynamic _getMediaCategory() {
    switch (this) {
      case SearchType.song:
        return Song;
      case SearchType.album:
        return Album;
      case SearchType.artist:
        return Artist;
    }
  }
}
