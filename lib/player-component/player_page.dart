import 'dart:typed_data';

import 'package:boombox/player-component/barrels/player_barrel.dart';
import 'package:boombox/player-component/barrels/playlist_barrel.dart';
import 'package:boombox/player-component/barrels/commons_barrel.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/player-component/helpers/player_functions_helper.dart';
import 'package:boombox/playlist-component/helpers/playlist_functions_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerPage();
}

class _PlayerPage extends State<PlayerPage> with TickerProviderStateMixin {
  final String _title = 'Player';

  late AnimationController _modalController;
  late AnimationController _artController;
  late Animation<Offset> _artAnimation;
  late AnimationController _infoController;
  late Animation<double> _infoAnimation;
  late AnimationController _lyricsController;
  late Animation<double> _lyricsAnimation;

  final ValueNotifier<int> _displayedActionCount = ValueNotifier<int>(0);
  // final ValueNotifier<bool> _onClipModeActive = ValueNotifier<bool>(false);

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

    _artController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _artAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.1, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _artController,
        curve: Curves.linear,
      ),
    );

    _infoController = AnimationController(
      vsync: this,
      duration: const Duration(),
    );
    _infoAnimation = Tween(begin: 0.0, end: 1.0).animate(_infoController);
    _lyricsController = AnimationController(
      vsync: this,
      duration: const Duration(),
    );
    _lyricsAnimation = Tween(begin: 0.0, end: 1.0).animate(_lyricsController);
  }

  @override
  void dispose() {
    _modalController.stop();
    _modalController.dispose();
    _artController.stop();
    _artController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<PlayerPage>(title: _title),
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildPlayer(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Column(
      children: [
        Expanded(child: _buildTrackDisplay()),
        _buildActionBar(),
        _buildSeekBar(),
        _buildPlayerButtons(),
      ],
    );
  }

  Widget _buildTrackDisplay() {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getSequenceStateStream,
      builder: (context, snapshot) {
        if (snapshot.data?.sequence.isEmpty ?? true) {
          return const SizedBox.shrink();
        }
        final TrackInfo trackInfo =
            snapshot.data!.currentSource!.tag as TrackInfo;

        return Column(
          children: [
            _buildAlbumArt(trackInfo.art),
            _buildTrackInformation(trackInfo.title!, trackInfo.artist!),
          ],
        );
      },
    );
  }

  Widget _buildActionBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: PlayerActionBarWidget(
        onInfoPressed: _onInfoPressed,
        onLyricsPressed: _onLyricsPressed,
        onTrimActivePressed: (isActive) async =>
            await _onTrimActivePressed(isActive),
      ),
    );
  }

  Widget _buildAlbumArt(Uint8List? image) {
    return Expanded(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // Track Info
          ValueListenableBuilder(
            valueListenable: _displayedActionCount,
            builder: (context, value, child) => AnimatedOpacity(
              key: UniqueKey(),
              opacity: _infoAnimation.value,
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: TrackInfoWidget(key: UniqueKey()),
              ),
            ),
          ),
          // Lyrics
          ValueListenableBuilder(
            valueListenable: _displayedActionCount,
            builder: (context, value, child) => AnimatedOpacity(
              key: UniqueKey(),
              opacity: _lyricsAnimation.value,
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: LyricsWidget(key: UniqueKey()),
              ),
            ),
          ),
          SlideTransition(
            position: _artAnimation,
            child: Hero(
              tag: 'ALBUM_ART',
              child: ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: image!.isEmpty
                    ? Image.asset('assets/images/cd.png')
                    : Image.memory(image),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInformation(String name, String artist) {
    return ListTile(
      title: Text(name),
      subtitle: Text(
        artist,
        style: Theme.of(context).textTheme.bodyMedium?.merge(
              TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
      ),
    );
  }

  Widget _buildSeekBar() {
    // Display seek bar. Using StreamBuilder, this widget rebuilds
    // each time the position, buffered position or duration changes.
    return StreamBuilder<PositionData>(
      stream: Provider.of<PlayerService>(context).getPositionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return SeekBarWidget(
          key: UniqueKey(),
          duration: positionData?.duration ?? Duration.zero,
          position: positionData?.position ?? Duration.zero,
          bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
          onValueChanged: (duration) =>
              PlayerFunctionsHelper().onSeekBarPositionChangedAsync(
            context,
            duration,
          ),
          onRangeValueChanged: (range) async =>
              await PlayerFunctionsHelper().onSeekBarRangeChangedAsync(
            context,
            range,
          ),
        );
      },
    );
  }

  Widget _buildPlayerButtons() {
    return PlayerButtonsWidget(
      sender: 'PLAYER',
      onPlayerModeChanged: (mode) async =>
          await PlayerFunctionsHelper().onPlayerModeChangedAsync(
        context,
        mode,
      ),
      onPreviousTrackPressed: () async =>
          await PlayerFunctionsHelper().onPreviousTrackPressedAsync(context),
      onPlayerStateChanged: (state) async =>
          await PlayerFunctionsHelper().onPlayerStateChangedAsync(
        context,
        state,
      ),
      onNextTrackPressed: () async =>
          await PlayerFunctionsHelper().onNextTrackPressedAsync(context),
      onPlaylistPressed: _onPlaylistPressed,
    );
  }

  void _onPlaylistPressed() async {
    await BottomSheetModalHelper.showModal(
      context,
      transitionController: _modalController,
      child: PlaylistModalWidget(
        onPlaylistSongSelected: (isPlaying, path) async =>
            await PlayerFunctionsHelper().onPlaylistSongSelectedAsync(
          context,
          isPlaying,
          path,
        ),
        onPlaylistReordered: (songs) => _onPlaylistReordered(songs),
        onPlaylistSweepPressed: (playlist) =>
            PlaylistFunctionsHelper().onPlaylistSweepAsync(context, playlist),
        onSavePlaylistPressed: (songs) => _onSavePlaylistPressed(songs),
      ),
    );
  }

  void _onPlaylistReordered(List<PlaylistSong> songs) {}

  void _onSavePlaylistPressed(List<PlaylistSong> songs) async {
    Playlist playlist = Playlist(
      id: -1,
      date: '',
      name: 'New Playlist',
      tracks: songs.length,
      songs: songs,
    );
    PageNavigator.navigateTo(
      context,
      PlaylistWidget(playlist: playlist),
    );
  }

  void _onInfoPressed() async {
    if (_lyricsController.isCompleted) return;
    _prepareArtAnimationOffset(true);

    if (_artAnimation.status == AnimationStatus.completed) {
      await _infoController.reverse();
      await _artController.reverse();
    } else {
      await _artController.forward();
      await _infoController.forward();
    }
    _displayedActionCount.value = _displayedActionCount.value++;
  }

  void _onLyricsPressed() async {
    if (_infoController.isCompleted) return;
    _prepareArtAnimationOffset(false);

    if (_artAnimation.status == AnimationStatus.completed) {
      await _lyricsController.reverse();
      await _artController.reverse();
    } else {
      await _artController.forward();
      await _lyricsController.forward();
    }
    _displayedActionCount.value = _displayedActionCount.value++;
  }

  void _prepareArtAnimationOffset(bool isInfo) async {
    _artAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isInfo ? -1.1 : 1.1, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _artController,
        curve: Curves.linear,
      ),
    );
    // ..addListener(() => setState(() {}));
  }

  Future<void> _onTrimActivePressed(bool isActive) async {}
}
