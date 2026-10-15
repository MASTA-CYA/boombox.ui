import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/player-component/models/enums/playlist_mode_enum.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/empty_playlist_view.dart';
import 'package:boombox/player-component/widgets/player_playlist_song_view.dart';
import 'package:boombox/player-component/widgets/playlist_header_controls.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PlaylistModalWidget extends StatelessWidget {
  final void Function(bool isPlaying, String path) onPlaylistSongSelected;
  final void Function(Playlist playlist) onPlaylistSweepPressed;
  final void Function(List<PlaylistSong> _songs) onSavePlaylistPressed;
  final void Function(List<PlaylistSong> songs) onPlaylistReordered;

  PlaylistModalWidget({
    super.key,
    required this.onPlaylistSongSelected,
    required this.onPlaylistSweepPressed,
    required this.onSavePlaylistPressed,
    required this.onPlaylistReordered,
  });

  final ValueNotifier<PlaylistMode> _mode =
      ValueNotifier<PlaylistMode>(PlaylistMode.simple);

  List<PlaylistSong>? _songs = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getPlaylistStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future:
                Provider.of<PlayerService>(context).getActivePlaylistAsync(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                _songs = snapshot.data!.songs;
                return _buildModalScaffold(
                  context,
                  snapshot.data!.name,
                  snapshot.data!,
                );
              } else {
                return const CircularProgressIndicatorWidget();
              }
            },
          );
        } else {
          _songs = snapshot.data!.songs;
          return _buildModalScaffold(
            context,
            snapshot.data!.name,
            snapshot.data!,
          );
        }
      },
    );
  }

  Widget _buildModalScaffold(
    BuildContext context,
    String name,
    Playlist playlist,
  ) {
    return Column(
      children: [
        _buildPlaylistHeader(context, name, playlist),
        playlist.songs.isEmpty
            ? const EmptyPlaylistWidget()
            : Expanded(child: _buildPlaylistSongs(context, playlist.songs)),
      ],
    );
  }

  Widget _buildPlaylistHeader(
      BuildContext context, String name, Playlist playlist) {
    return PlaylistHeaderControlsWidget(
      name: name,
      onPlaylistModeChanged: (mode) => _onPlaylistModeChanged(mode),
      onPlaylistSweepPressed: () => _onPlaylistSweepPressed(playlist),
      onSavePlaylistPressed: _onSavePlaylistPressed,
    );
  }

  Widget _buildPlaylistSongs(BuildContext context, List<PlaylistSong> songs) {
    return ValueListenableBuilder(
      valueListenable: _mode,
      builder: (context, mode, child) => PlayerPlaylistSongViewWidget(
        songs: songs,
        onSongSelected: (isPlaying, path) =>
            onPlaylistSongSelected(isPlaying, path),
        onSongReordered: (songs) => onPlaylistReordered(songs),
        enableDragBehavior: mode == PlaylistMode.reorder,
      ),
    );
  }

  void _onPlaylistSweepPressed(Playlist playlist) {
    final Playlist newPlaylist = Playlist(
      id: playlist.id,
      date: playlist.date,
      image: playlist.image,
      name: playlist.name,
      tracks: 1,
      songs: playlist.songs.where((song) => song.isPlaying).toList(),
    );
    // _isPlaylistCleared.value = true;
    onPlaylistSweepPressed(newPlaylist);
  }

  void _onSavePlaylistPressed() {
    if (_songs?.isNotEmpty ?? false) onSavePlaylistPressed(_songs!);
  }

  void _onPlaylistModeChanged(PlaylistMode mode) {
    _mode.value = mode;
  }
}
