import 'dart:ui';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/playing_icon.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlayerPlaylistSongViewWidget extends StatefulWidget {
  final List<PlaylistSong> songs;
  final void Function(bool isPlaying, String path) onSongSelected;
  final void Function(List<PlaylistSong> songs) onSongReordered;
  final bool enableDragBehavior;

  const PlayerPlaylistSongViewWidget({
    super.key,
    required this.songs,
    required this.onSongSelected,
    required this.onSongReordered,
    this.enableDragBehavior = false,
  });

  @override
  State<StatefulWidget> createState() => _PlayerPlaylistSongViewWidget();
}

class _PlayerPlaylistSongViewWidget
    extends State<PlayerPlaylistSongViewWidget> {
  late List<PlaylistSong> lsSongs;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();

    lsSongs = widget.songs;
    _isPlaying = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.enableDragBehavior
        ? _buildReorderableList()
        : _buildSimpleList();
  }

  Widget _buildSimpleList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: lsSongs.length,
      itemBuilder: (context, index) => Column(
        children: _buildTrackDetails(index),
      ),
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      proxyDecorator: _proxyDecorator,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: lsSongs.length,
      onReorder: (oldIndex, newIndex) =>
          _onListOrderChanged(oldIndex, newIndex),
      itemBuilder: (context, index) {
        return ReorderableDelayedDragStartListener(
          key: UniqueKey(),
          index: index,
          child: Column(
            key: UniqueKey(),
            children: _buildTrackDetails(index),
          ),
        );
      },
    );
  }

  List<Widget> _buildTrackDetails(int index) {
    return <Widget>[
      ListTile(
        leading: ClipRRect(
          child: Image.memory(widget.songs.elementAt(index).song.art),
        ),
        title: Text(lsSongs.elementAt(index).song.name),
        subtitle: Text(
          lsSongs.elementAt(index).song.artist,
          style: Theme.of(context).textTheme.bodyMedium?.merge(
                TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
        ),
        trailing: _buildTrailingIcon(index),
        onTap: () => widget.enableDragBehavior
            ? null
            : widget.onSongSelected(
                _isPlaying,
                widget.songs.elementAt(index).song.path,
              ),
      ),
      lsSongs.length == 1
          ? const SizedBox.shrink()
          : const Divider(
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
    ];
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color draggableItemColor = colorScheme.secondary;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: draggableItemColor,
          shadowColor: draggableItemColor,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildTrailingIcon(int index) {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getSequenceStateStream,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          duration: const Duration(milliseconds: 400),
          reverseDuration: const Duration(milliseconds: 400),
          child: _buildTrailingStreamIcon(snapshot, index),
        );
      },
    );
  }

  Widget _buildTrailingStreamIcon(
      AsyncSnapshot<SequenceState?> snapshot, int index) {
    if (snapshot.hasData && !widget.enableDragBehavior) {
      TrackInfo info = snapshot.data!.currentSource!.tag as TrackInfo;
      if (info.title!.equals(widget.songs.elementAt(index).song.name)) {
        return GestureDetector(
          child: PlayingIconWidget(
            useRandomPattern: false,
            onPlayerStateChanged: (isPlaying) =>
                _onPlayerStateChanged(isPlaying),
          ),
          onTap: () => widget.onSongSelected(
            _isPlaying,
            widget.songs.elementAt(index).song.path,
          ),
        );
      }
      return const SizedBox.shrink();
    } else {
      return Functions.isPlatformWeb()
          ? const SizedBox.shrink()
          : Icon(key: UniqueKey(), Icons.drag_handle);
    }
  }

  void _onListOrderChanged(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final PlaylistSong song = lsSongs.removeAt(oldIndex);
    lsSongs.insert(newIndex, song);
    widget.onSongReordered(lsSongs);
  }

  void _onPlayerStateChanged(bool isPlaying) {
    _isPlaying = isPlaying;
  }
}
