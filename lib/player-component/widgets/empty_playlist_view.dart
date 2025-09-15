import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';

class EmptyPlaylistWidget extends StatelessWidget {
  const EmptyPlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50,),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 100,
          child: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/playlist-placeholder.png'),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 150,
          ),
        ),
        Text(
          'PLAYLIST IS EMPTY',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
      ],
    );
  }
}
