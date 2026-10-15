import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';

class EmptyNewsFeedWidget extends StatelessWidget {
  const EmptyNewsFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        const SizedBox(height: 130),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 150,
          child: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/newspaper-2.png'),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 150,
          ),
        ),
        Text(
          'NEWS FEED IS EMPTY',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
      ],
    );
  }
}
