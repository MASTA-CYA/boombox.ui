import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/helpers/bottom_modal_helper.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/music-component/widgets/no_music.dart';
import 'package:boombox/music-component/widgets/song_view.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/player_page.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/mini-player/popup_mini_player.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/services/playlist_service.dart';
import 'package:boombox/playlist-component/widgets/playlists_view.dart';
import 'package:boombox/recently-played-component/services/recently_played_service.dart';
import 'package:boombox/settings-component/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentlyPlayedPage extends StatefulWidget {
  const RecentlyPlayedPage({super.key});

  @override
  State<StatefulWidget> createState() => _RecentlyPlayedPage();
}

class _RecentlyPlayedPage extends State<RecentlyPlayedPage> {
  final String _title = 'Played';

  final ValueNotifier<bool> _isPlayerHidden = ValueNotifier<bool>(false);

  Song? _addToPlaylist;

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<SettingsPage>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildPlayedScaffold(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayedScaffold() {
    return Column(
      children: [
        Expanded(
          child: _buildSongs(),
        ),
        _buildPopupMiniPlayer(),
      ],
    );
  }

  Widget _buildSongs() {
    return Consumer<RecentlyPlayedService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.getRecentlyPlayed(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isNotEmpty) {
              return SongViewWidget(
                songs: snapshot.data!,
                onSongSelected: (index) =>
                    _onSongSelected(snapshot.data!.elementAt(index)),
                onAddSongToPlaylistPressed: (index) async =>
                    _onAddSongToPlaylistPressed(
                  snapshot.data!.elementAt(index),
                ),
              );
            } else {
              return const NoMusicWidget();
            }
          } else {
            return const CircularProgressIndicatorWidget();
          }
        },
      ),
    );
  }

  Widget _buildPopupMiniPlayer() {
    return ValueListenableBuilder(
      valueListenable: _isPlayerHidden,
      builder: (context, isHidden, child) => StreamBuilder(
        stream: Provider.of<PlayerService>(context).getSequenceStateStream,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.hasData && !isHidden) {
            final TrackInfo? info =
                snapshot.data!.currentSource?.tag as TrackInfo?;
            if (!info.isNull) {
              child = PopupMiniPlayerWidget(
                song: info!,
                onShouldHidePressed: (shouldHide) =>
                    _onShouldHidePressed(shouldHide),
                onNavigatorToPlayerPressed: () => _navigateTo(
                  const PlayerPage(),
                  direction: TransitionDirection.btt,
                ),
              );
            } else {
              child = const SizedBox.shrink();
            }
          } else {
            child = const SizedBox.shrink();
          }

          return AnimatedSwitcher(
            transitionBuilder: (child, animation) => SlideTransition(
              position: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
                reverseCurve: Curves.easeOut,
              ).drive(
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ),
              ),
              child: child,
            ),
            duration: const Duration(seconds: 10),
            reverseDuration: const Duration(seconds: 5),
            child: child,
          );
        },
      ),
    );
  }

  _onShouldHidePressed(bool shouldHide) {
    _isPlayerHidden.value = shouldHide;
  }

  void _onSongSelected(Song song) async {
    _isPlayerHidden.value = false;
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).playSingleTrackAsync(song);
  }

  void _onAddSongToPlaylistPressed(Song song) async {
    _addToPlaylist = song;
    await BottomSheetModalHelper.showModal(context,
        child: _buildAddToPlaylistModal());
  }

  Widget _buildAddToPlaylistModal() {
    return PlaylistsWidget(
      isParentModal: true,
      onPlaylistSelected: (playlist) async => _onPlaylistSelected(playlist),
    );
  }

  void _onPlaylistSelected(Playlist playlist) async {
    bool wasSuccessful = await Provider.of<PlaylistService>(
      context,
      listen: false,
    ).addSongToPlaylistAsync(playlist, _addToPlaylist!);

    if (mounted) {
      SnackbarHelper.showProviderResult(
        context,
        wasSuccessful,
        message: 'Song added to playlist.',
      );
    }
  }

  void _navigateTo(
    Widget widget, {
    TransitionDirection direction = TransitionDirection.ltr,
  }) {
    PageNavigator.navigateTo<RecentlyPlayedPage>(
      context,
      widget,
      direction: direction,
    );
  }
}
