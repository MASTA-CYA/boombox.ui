// ignore_for_file: unused_import

import 'package:boombox/common/extensions.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/playing_icon.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class SongViewWidget extends StatefulWidget {
  final List<Song> songs;
  final void Function(int index) onSongSelected;
  final void Function(int id) onAddSongToPlaylistPressed;

  const SongViewWidget({
    super.key,
    required this.songs,
    required this.onSongSelected,
    required this.onAddSongToPlaylistPressed,
  });

  @override
  State<StatefulWidget> createState() => _SongViewWidget();
}

class _SongViewWidget extends State<SongViewWidget> {
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  final List<Widget> _songs = <Widget>[];
  late CancelableCompleter completer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        Future future = Future(() {});
        for (int i = 0; i < widget.songs.length; i++) {
          // completer = CancelableCompleter(
          //   onCancel: () {
          //     debugPrint('Canceled on index: $i');
          //   },
          // );
          if (mounted) {
            // completer.complete(
            future.then(
              (_) {
                if (mounted) {
                  return Future.delayed(
                    const Duration(milliseconds: 100),
                    () {
                      if (mounted) {
                        _songs.add(_buildSongListTile(i));
                        _key.currentState?.insertItem(
                          _songs.length - 1,
                          duration: const Duration(seconds: 7),
                        );
                      }
                    },
                  );
                }
              },
              // ),
            );
          }
        }
      },
    );
  }

  // @override
  // void dispose() {
  //   // completer.operation.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder(
    //   stream: Provider.of<PlayerService>(context).getSequenceStateStream,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       _updatePlayingSong(snapshot);
    //     }

    return AnimatedList(
      key: _key,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      initialItemCount: _songs.length,
      itemBuilder: (context, index, animation) => SlideTransition(
        position: CurvedAnimation(
          curve: Curves.easeOut,
          parent: animation,
        ).drive(
          Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ),
        ),
        child: _songs.elementAt(index),
      ),
    );
    // },
    // );
  }

  Widget _buildSongListTile(int index) {
    return Column(
      children: [
        ListTile(
          leading: ClipRRect(
            child: widget.songs.elementAt(index).art.isEmpty
                ? Image.asset('assets/images/cd.png')
                : Image.memory(widget.songs.elementAt(index).art),
          ),
          title: Text(widget.songs.elementAt(index).name),
          subtitle: Text(
            widget.songs.elementAt(index).artist,
            style: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
          ),
          trailing: GestureDetector(
            child: const Icon(Icons.add),
            // _buildPlayingIcon(snapshot, index),
            onTap: () => widget.onAddSongToPlaylistPressed(index),
            onLongPress: () {},
          ),
          onTap: () => widget.onSongSelected(index),
        ),
        const Divider(
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  // Widget _buildPlayingIcon(AsyncSnapshot<SequenceState?>? snapshot, int index) {
  //   if (!snapshot.isNull) {
  //     if (!snapshot!.hasData) return const SizedBox.shrink();

  //     TrackInfo? info = snapshot.data!.currentSource?.tag;
  //     if (!info.isNull &&
  //         widget.songs.elementAt(index).path.equals(info!.path!)) {
  //       return const PlayingIconWidget(useRandomPattern: false);
  //     } else {
  //       return const Icon(
  //         Icons.add,
  //       );
  //     }
  //   } else {
  //     return const Icon(
  //       Icons.add,
  //     );
  //   }
  // }

  // void _updatePlayingSong(AsyncSnapshot<SequenceState?> snapshot) {
  //   final TrackInfo info = snapshot.data!.currentSource?.tag as TrackInfo;
  //   final List<Song> songs = widget.songs
  //       .where((song) => song.path.equals(info.path ?? ''))
  //       .toList();
  //   if (songs.isNotEmpty && _songs.isNotEmpty) {
  //     final int index = widget.songs.indexOf(songs.first);
  //     _songs.removeAt(index);
  //     _songs.insert(index, _buildSongListTile(index, snapshot: snapshot));
  //     _key.currentState?.insertItem(
  //       index,
  //       duration: const Duration(seconds: 7),
  //     );
  //   }
  // }
}
