import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';

class NoSortOptionsModalWidget extends StatelessWidget {
  const NoSortOptionsModalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 150,
          child: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/no-filter.png'),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 150,
          ),
        ),
        Text(
          'NO SORT OPTIONS AVAILABLE',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
      ],
    );
  }
}
