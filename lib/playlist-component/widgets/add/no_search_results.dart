import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';

class NoResultsForSearchWidget extends StatelessWidget {
  const NoResultsForSearchWidget({super.key});

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
              AssetImage('assets/images/cd.png'),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 150,
          ),
        ),
        Text(
          'NO MUSIC FOUND',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(8, 20, 8, 0),
          child: const Text(
              'The search yielded no results. Try changing the search.'),
        ),
      ],
    );
  }
}
