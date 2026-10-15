import 'package:boombox/common/helpers/bottom_modal_helper.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/player-component/helpers/player_functions_helper.dart';
import 'package:boombox/player-component/models/position_data_model.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/player_page.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/player_buttons.dart';
import 'package:boombox/player-component/widgets/playlist_modal.dart';
import 'package:boombox/player-component/widgets/seek_bar.dart';
import 'package:boombox/playlist-component/helpers/playlist_functions_helper.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:boombox/playlist-component/widgets/playlist_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:provider/provider.dart';

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MiniPlayerWidget();
}

class _MiniPlayerWidget extends State<MiniPlayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _modalController;
  late AnimationController _controller;
  late AnimationController _seekbarController;

  late Animation<Offset> _playerButtonAnimation;
  late Animation<Offset> _trackInfoAnimation;
  late Animation<double> _seekbarAnimation;

  @override
  void initState() {
    super.initState();

    _modalController = BottomSheet.createAnimationController(this);
    // Animation duration for displaying the BottomSheet
    _modalController.duration = const Duration(milliseconds: 400);
    // Animation duration for retracting the BottomSheet
    _modalController.reverseDuration = const Duration(milliseconds: 400);
    // Set animation curve duration for the BottomSheet
    _modalController.drive(CurveTween(curve: Curves.elasticInOut));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _seekbarController = AnimationController(
      vsync: this,
      duration: Duration.zero,
    );

    _playerButtonAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _trackInfoAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _seekbarAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _seekbarController, curve: Curves.easeIn),
    )..addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.forward();
      await _seekbarController.forward();
    });
  }

  @override
  void dispose() {
    _modalController.stop();
    _modalController.dispose();
    _seekbarController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTrackInformation(),
        _buildSeekBar(),
        _buildPlayerButtons(),
      ],
    );
  }

  Widget _buildTrackInformation() {
    return StreamBuilder<audio.SequenceState?>(
      stream: Provider.of<PlayerService>(context).getSequenceStateStream,
      builder: (context, snapshot) {
        if (snapshot.data?.sequence.isEmpty ?? true) {
          return const SizedBox.shrink();
        }

        final TrackInfo trackInfo =
            snapshot.data!.currentSource!.tag as TrackInfo;
        return SlideTransition(
          position: _trackInfoAnimation,
          child: ListTile(
            leading: Hero(
              tag: 'ALBUM_ART',
              child: ClipRRect(
                child:
                    trackInfo.art!.isNotEmpty
                        ? Image.memory(trackInfo.art!)
                        : Image.asset('assets/images/cd.png'),
              ),
            ),
            title: Text(trackInfo.title!),
            subtitle: Text(
              trackInfo.artist!,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.keyboard_arrow_up),
              onPressed:
                  () => _navigateTo(
                    const PlayerPage(),
                    direction: TransitionDirection.btt,
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeekBar() {
    // Display seek bar. Using StreamBuilder, this widget rebuilds
    // each time the position, buffered position or duration changes.
    return StreamBuilder<PositionData>(
      stream: Provider.of<PlayerService>(context).getPositionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return AnimatedOpacity(
          opacity: _seekbarAnimation.value,
          duration: const Duration(seconds: 5),
          curve: Curves.easeOut,
          child: SeekBarWidget(
            key: UniqueKey(),
            duration: positionData?.duration ?? Duration.zero,
            position: positionData?.position ?? Duration.zero,
            bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
            onValueChanged:
                (duration) => PlayerFunctionsHelper()
                    .onSeekBarPositionChangedAsync(context, duration),
          ),
        );
      },
    );
  }

  Widget _buildPlayerButtons() {
    return SlideTransition(
      position: _playerButtonAnimation,
      child: PlayerButtonsWidget(
        sender: 'MINI',
        onPlayerModeChanged:
            (mode) async => await PlayerFunctionsHelper()
                .onPlayerModeChangedAsync(context, mode),
        onPreviousTrackPressed:
            () async => await PlayerFunctionsHelper()
                .onPreviousTrackPressedAsync(context),
        onPlayerStateChanged:
            (state) async => await PlayerFunctionsHelper()
                .onPlayerStateChangedAsync(context, state),
        onNextTrackPressed:
            () async =>
                await PlayerFunctionsHelper().onNextTrackPressedAsync(context),
        onPlaylistPressed: _onPlaylistPressed,
      ),
    );
  }

  void _onPlaylistPressed() async {
    await BottomSheetModalHelper.showModal(
      context,
      transitionController: _modalController,
      child: PlaylistModalWidget(
        onPlaylistSongSelected:
            (isPlaying, path) async => await PlayerFunctionsHelper()
                .onPlaylistSongSelectedAsync(context, isPlaying, path),
        onPlaylistReordered: (songs) => _onPlaylistReordered(songs),
        onPlaylistSweepPressed:
            (playlist) => PlaylistFunctionsHelper().onPlaylistSweepAsync(
              context,
              playlist,
            ),
        onSavePlaylistPressed: (songs) => _onSavePlaylistPressed(songs),
      ),
    );
  }

  void _onPlaylistReordered(List<PlaylistSong> songs) {}

  void _onSavePlaylistPressed(List<PlaylistSong> songs) async {
    Playlist playlist = Playlist(
      id: 0,
      date: DateFormat.yMd().format(DateTime.now()),
      name: 'New Playlist',
      tracks: songs.length,
      songs: songs,
    );
    _navigateTo(PlaylistWidget(playlist: playlist));
  }

  void _navigateTo(
    Widget widget, {
    TransitionDirection direction = TransitionDirection.ltr,
  }) {
    PageNavigator.navigateTo<MiniPlayerWidget>(
      context,
      widget,
      direction: direction,
    );
  }
}
