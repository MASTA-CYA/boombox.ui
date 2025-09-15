import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/helpers/enums/snackbar_type_enum.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/models/enums/download_action_enum.dart';
import 'package:boombox/music-component/widgets/album_header.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/playing_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class AlbumSongsWidget extends StatefulWidget {
  final Album album;

  const AlbumSongsWidget({
    super.key,
    required this.album,
  });

  @override
  State<StatefulWidget> createState() => _AlbumSongsWidget();
}

class _AlbumSongsWidget extends State<AlbumSongsWidget> {
  final String _title = 'Album';

  late ScrollController _scrollController;
  final ValueNotifier _canScrollToTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() => _onAlbumPageScroll());
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<AlbumSongsWidget>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildAlbumScaffold(),
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
          resizeToAvoidBottomInset: true,
        ),
      ),
    );
  }

  Widget _buildAlbumScaffold() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildAlbumHeader(),
          _buildAlbumSongs(),
        ],
      ),
    );
  }

  Widget _buildAlbumHeader() {
    return AlbumHeaderWidget(
      album: widget.album,
      onDownloadActionSelected: (action) => _onDownloadActionSelected(action),
    );
  }

  Widget _buildAlbumSongs() {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getSequenceStateStream,
      builder: (context, snapshot) => ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: widget.album.songs.length,
        itemBuilder: (context, index) => Column(
          children: [
            ListTile(
              title: Text(widget.album.songs.elementAt(index).name),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.album.artist,
                    style: Theme.of(context).textTheme.bodyMedium?.merge(
                          TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                  ),
                  Text(
                    DateFormat('mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.album.songs.elementAt(index).duration),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.merge(
                          TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                  ),
                ],
              ),
              trailing: _buildPlayingIcon(snapshot, index),
              onTap: () async => _onPlaySongTapped(index),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingIcon(AsyncSnapshot<SequenceState?> snapshot, int index) {
    if (!snapshot.hasData) return const SizedBox.shrink();

    TrackInfo? info = snapshot.data!.currentSource?.tag;
    if (!info.isNull &&
        widget.album.songs.elementAt(index).path.equals(info!.path!)) {
      return const PlayingIconWidget(useRandomPattern: false);
    } else {
      return const SizedBox.shrink();
    }
  }

  void _onPlaySongTapped(int index) async {
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).playAlbumAsync(
      widget.album.songs,
      index,
    );
  }

  void _onDownloadActionSelected(DownloadAction action) {
    String message;

    switch (action) {
      case DownloadAction.none:
        message = "Download cancelled";
        break;
      case DownloadAction.later:
        message = "Download scheduled for later";
        break;
      case DownloadAction.now:
        message = "Download will begin in 10 seconds";
        break;
    }

    SnackbarHelper.showMessage(
      context,
      SnackbarType.information,
      message,
    );
  }

  void _scrollToTopPressed() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onAlbumPageScroll() {
    _canScrollToTop.value = _scrollController.position.extentBefore > 320;
  }
}
