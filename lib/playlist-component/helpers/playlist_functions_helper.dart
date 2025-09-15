import 'package:boombox/music-component/music_barrel.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';

class PlaylistFunctionsHelper {
  static final PlaylistFunctionsHelper _instance =
    PlaylistFunctionsHelper._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory PlaylistFunctionsHelper() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  PlaylistFunctionsHelper._internal() {}

  Future<void> onPlaylistReorderedAsync(List<PlaylistSong> songs) async {}

  Future<void> onPlaylistSweepAsync(
    BuildContext context,
    Playlist playlist,
  ) async {
    if (!context.mounted) return;
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).sweepActivePlayingAsync(playlist);
  }

  Future<void> onSavePlaylistPressedAsync(List<PlaylistSong> songs) async {
    
  }
}