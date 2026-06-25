import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/models/enums/download_action_enum.dart';
import 'package:boombox/music-component/widgets/download_media_icon_widget.dart';
import 'package:flutter/material.dart';

class AlbumHeaderWidget extends StatefulWidget {
  final Album album;
  final Function(DownloadAction action) onDownloadActionSelected;

  const AlbumHeaderWidget({
    super.key,
    required this.album,
    required this.onDownloadActionSelected,
  });

  @override
  State<StatefulWidget> createState() => _AlbumHeaderWidget();
}

class _AlbumHeaderWidget extends State<AlbumHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Card(
        margin: Theme.of(context).cardTheme.margin,
        child: Column(
          children: [
            _buildAlbumImage(),
            _buildNameAndDetails(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAlbumImage() {
    return Expanded(
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              image: DecorationImage(
                image: widget.album.art.isEmpty
                    ? Image.asset('assets/images/album.png').image
                    : Image.memory(widget.album.art).image,
                fit: BoxFit.fill,
                invertColors:
                    widget.album.art.isEmpty &&
                    Theme.of(context).brightness.equals(Brightness.dark),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              color: Colors.transparent
                  .withOpacity(0.5), //ColorHelper.darken(Colors.grey, 73),
              child: Container(
                margin: const EdgeInsets.all(6),
                child: DownloadMediaIconWidget(
                  onDownloadActionSelected: (action) =>
                      widget.onDownloadActionSelected(action),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameAndDetails() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.album.name,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge?.merge(
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  widget.album.artist.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.merge(
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                ),
                _buildDetailsSeparator(),
                Text(
                  '${widget.album.tracks.toString()} songs',
                  style: Theme.of(context).textTheme.bodyMedium?.merge(
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                ),
                _buildDetailsSeparator(),
                Text(
                  widget.album.year == 0
                      ? 'Unknown'
                      : widget.album.year.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.merge(
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSeparator() {
    return Container(
      width: 5.5,
      height: 5.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // Widget _buildButtonBar() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 2),
  //     child: Align(
  //       alignment: Alignment.center,
  //       child: ButtonBar(
  //         alignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           PlaylistButtonWidget(
  //             icon: const Icon(
  //               Icons.play_arrow_sharp,
  //               size: 24.5,
  //             ),
  //             text: 'Play',
  //             onClicked: () async => {},
  //           ),
  //           PlaylistButtonWidget(
  //             icon: const Icon(
  //               Icons.shuffle,
  //               size: 24.5,
  //             ),
  //             text: 'Shuffle',
  //             onClicked: () async => {},
  //           ),
  //           PlaylistIconButtonWidget(
  //             icon: const Icon(
  //               Icons.edit,
  //               // size: 28,
  //             ),
  //             onClicked: _onPlaylistEditPressed,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
