import 'dart:ui';
import 'package:boombox/common/functions.dart';
import 'package:boombox/playlist-component/models/edit_mode_enum.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:boombox/playlist-component/widgets/edit/edit_mode_swapper.dart';
import 'package:flutter/material.dart';

class EditPlaylistSongViewWidget extends StatefulWidget {
  final List<PlaylistSong> songs;
  final void Function(List<PlaylistSong> songs) onSongsUpdated;

  const EditPlaylistSongViewWidget({
    super.key,
    required this.songs,
    required this.onSongsUpdated,
  });

  @override
  State<StatefulWidget> createState() => _EditPlaylistSongViewWidget();
}

class _EditPlaylistSongViewWidget extends State<EditPlaylistSongViewWidget>
    with SingleTickerProviderStateMixin {
  late EditMode _mode;
  late List<PlaylistSong> _lsSongs;

  @override
  void initState() {
    super.initState();

    _lsSongs = widget.songs;
    _mode = EditMode.reorder;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEditModeSwapper(),
        _buildSongsList(),
      ],
    );
  }

  Widget _buildEditModeSwapper() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: EditModeSwapperWidget(
        onEditModeChanged: (mode) => _onEditModeChanged(mode),
      ),
    );
  }

  Widget _buildSongsList() {
    return ReorderableListView.builder(
      proxyDecorator: _proxyDecorator,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      buildDefaultDragHandles: _mode == EditMode.reorder,
      itemCount: _lsSongs.length,
      onReorder: (oldIndex, newIndex) =>
          _onListOrderChanged(oldIndex, newIndex),
      itemBuilder: (context, index) {
        return Column(
          key: UniqueKey(),
          children: [
            ListTile(
              leading: ClipRRect(
                child: Image.memory(widget.songs.elementAt(index).song.art),
              ),
              title: Text(_lsSongs.elementAt(index).song.name),
              subtitle: Text(
                _lsSongs.elementAt(index).song.artist,
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
              ),
              trailing: _buildTrailingIcon(index),
            ),
            const Divider(
              thickness: 1,
              indent: 10,
              endIndent: 10,
            )
          ],
        );
      },
    );
  }

  Widget _buildTrailingIcon(int index) {
    return _mode == EditMode.reorder
        ? Functions.isPlatformWeb()
            ? const SizedBox.shrink()
            : const Icon(Icons.drag_handle)
        : GestureDetector(
            child: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onTap: () => _onSongRemoved(index),
          );
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

  void _onListOrderChanged(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final PlaylistSong song = _lsSongs.removeAt(oldIndex);
    _lsSongs.insert(newIndex, song);

    widget.onSongsUpdated(_lsSongs);
  }

  void _onEditModeChanged(EditMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  void _onSongRemoved(int index) {
    if (_lsSongs.length > 1) {
      _lsSongs.removeAt(index);
      widget.onSongsUpdated(_lsSongs);
    }
    setState(() {});
  }
}
