import 'package:boombox/player-component/widgets/playing_icon.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:flutter/material.dart';

class PlaylistSongViewWidget extends StatefulWidget {
  final List<PlaylistSong> songs;
  final void Function(String path, bool isPlaying) onSongSelected;

  const PlaylistSongViewWidget({
    super.key,
    required this.songs,
    required this.onSongSelected,
  });

  @override
  State<StatefulWidget> createState() => _PlaylistSongViewWidget();
}

class _PlaylistSongViewWidget extends State<PlaylistSongViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: widget.songs.length,
      itemBuilder: (context, index) => Column(
        children: [
          ListTile(
            onTap: () => widget.onSongSelected(
              widget.songs.elementAt(index).song.path,
              widget.songs.elementAt(index).isPlaying,
            ),
            title: Text(widget.songs.elementAt(index).song.name),
            subtitle: Text(
              widget.songs.elementAt(index).song.artist,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
            ),
            trailing: widget.songs.elementAt(index).isPlaying
                ? GestureDetector(
                    onTap: () => widget.onSongSelected(
                      widget.songs.elementAt(index).song.path,
                      widget.songs.elementAt(index).isPlaying,
                    ),
                    child: PlayingIconWidget(
                      onPlayerStateChanged: (isPlaying) {},
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Divider(
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
        ],
      ),
    );
  }
}
