import 'package:boombox/common/constants.dart';
import 'package:boombox/player-component/widgets/action-bar/track_info.dart';
import 'package:flutter/material.dart';

class NoActionWidget<T> extends StatelessWidget {
  const NoActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 100,
          child: ImageIcon(
            ResizeImage(
              AssetImage(
                T == TrackInfoWidget
                    ? 'assets/images/information.png'
                    : 'assets/images/lyrics.png',
              ),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 150,
          ),
        ),
        Text(
          T == TrackInfoWidget ? 'NO TRACK INFORMATION' : 'NO LYRICS AVAILABLE',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
      ],
    );
  }
}
