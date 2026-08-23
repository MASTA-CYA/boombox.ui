import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';

class NoPlaylistViewWidget extends StatelessWidget {
  final bool? minify;

  const NoPlaylistViewWidget({
    super.key,
    this.minify = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: minify! ? 40 : 80),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 150,
          child: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/playlist.png'),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 150,
          ),
        ),
        Text(
          'NO PLAYLISTS FOUND',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
      ],
    );
  }
}
