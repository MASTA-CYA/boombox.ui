import 'dart:typed_data';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/music-component/music_barrel.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:boombox/playlist-component/services/playlist_service.dart';
import 'package:boombox/playlist-component/widgets/edit/edit_playlist_view.dart';
import 'package:boombox/playlist-component/widgets/playlist_header.dart';
import 'package:boombox/playlist-component/widgets/playlist_song_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistWidget extends StatefulWidget {
  final Playlist playlist;
  const PlaylistWidget({
    super.key,
    required this.playlist,
  });

  @override
  State<StatefulWidget> createState() => _PlaylistWidget();
}

class _PlaylistWidget extends State<PlaylistWidget> {
  final String _title = 'Playlist';

  late ScrollController _scrollController;
  final ValueNotifier _canScrollToTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() => _onPlaylistPageScroll());
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<PlaylistWidget>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildPlaylistDetails(),
          ),
          floatingActionButton: ValueListenableBuilder(
            valueListenable: _canScrollToTop,
            builder: (context, canScroll, child) {
              return canScroll
                  ? Container(
                      margin: const EdgeInsets.only(top: 70),
                      child: FloatingActionButton(
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                        onPressed: () => _scrollToTopPressed(),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        ),
      ),
    );
  }

  Widget _buildPlaylistDetails() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          PlaylistHeaderWidget(
            playlist: widget.playlist,
            onPlaylistEditPressed: _onPlaylistEditPressed,
          ),
          PlaylistSongViewWidget(
            songs: widget.playlist.songs,
            onSongSelected: (path, isPlaying) async =>
                await _onSongSelected(path, isPlaying),
          ),
        ],
      ),
    );
  }

  Future<void> _onSongSelected(String path, bool isPlaying) async {
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).playSelectedPlaylistSongAsync(path, isPlaying);
  }

  void _scrollToTopPressed() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onPlaylistPageScroll() {
    _canScrollToTop.value = _scrollController.position.extentBefore > 350;
  }

  void _onPlaylistEditPressed() {
    PageNavigator.navigateTo(
      context,
      EditPlaylistWidget(
        playlist: widget.playlist,
        onSaveChangesPressed:
            (Uint8List? image, String name, List<PlaylistSong> songs) async =>
                _onSaveChangesPressed(image, name, songs),
      ),
    );
  }

  void _onSaveChangesPressed(
      Uint8List? image, String name, List<PlaylistSong> songs) async {
    // Playlist playlist = Playlist(
    //   id: widget.playlist.id,
    //   date: widget.playlist.date,
    //   image: image,
    //   name: name,
    //   tracks: widget.playlist.tracks,
    //   songs: widget.playlist.songs,
    // );
    bool result = await Provider.of<PlaylistService>(context, listen: false)
        .editPlaylistAsync(widget.playlist.id, widget.playlist.date,
            image ?? widget.playlist.image, name, songs.length, songs);
    if (mounted) {
      SnackbarHelper.showProviderResult(context, result, message: '');
    }

    // PageNavigator.navigateBack(context);
  }
}
