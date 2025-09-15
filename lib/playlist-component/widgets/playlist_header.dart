import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/player-component/barrels/player_barrel.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/services/playlist_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistHeaderWidget extends StatefulWidget {
  final Playlist playlist;
  final void Function() onPlaylistEditPressed;
  const PlaylistHeaderWidget({
    super.key,
    required this.playlist,
    required this.onPlaylistEditPressed,
  });

  @override
  State<StatefulWidget> createState() => _PlaylistHeaderWidget();
}

class _PlaylistHeaderWidget extends State<PlaylistHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 350),
      child: Card(
        margin: Theme.of(context).cardTheme.margin,
        child: Column(
          children: [
            _buildPlaylistImage(),
            _buildPlaylistDetails(),
            _buildButtonBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistImage() {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                // widget.playlist.image.isNull &&
                //         widget.playlist.songs.first.song.art.isNull
                //     ? const ImageIcon(
                //         // size: 150,
                //         ResizeImage(
                //           AssetImage('assets/images/playlist-placeholder.png'),
                //           width: 644,
                //           height: 384,
                //         ),
                //       ).image!
                //     :
                ResizeImage(
              width: 644,
              height: 384,
              Image.memory(
                widget.playlist.image ?? widget.playlist.songs.first.song.art,
                fit: BoxFit.cover,
              ).image,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      child: buildNameAndDate(),
    );
  }

  Widget buildNameAndDate() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.playlist.name,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleMedium?.merge(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.playlist.date,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Align(
        alignment: Alignment.center,
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              elevation: 4,
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.play_arrow_sharp),
                onPressed: () async => await _onPlayPressed(),
              ),
            ),
            Material(
              elevation: 4,
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(
                  Icons.shuffle,
                ),
                onPressed: () async => await _onShufflePlayPressed(),
              ),
            ),
            Material(
              elevation: 4,
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                onPressed: _onPlaylistEditPressed,
              ),
            ),
            Material(
              elevation: 4,
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () async => _onPlaylistDeletePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPlaylistEditPressed() {
    widget.onPlaylistEditPressed();
  }

  Future<void> _onPlaylistDeletePressed() async {
    bool wasSuccessful = await Provider.of<PlaylistService>(
      context,
      listen: false,
    ).removePlaylistAsync(widget.playlist);
    if (mounted) {
      SnackbarHelper.showProviderResult(
        context,
        wasSuccessful,
        message: 'Playlist successfully removed',
      );
    }
  }

  Future<void> _onShufflePlayPressed() async {
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).playPlaylistAsync(widget.playlist);
  }

  Future<void> _onPlayPressed() async {
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).playPlaylistAsync(widget.playlist);
  }
}
