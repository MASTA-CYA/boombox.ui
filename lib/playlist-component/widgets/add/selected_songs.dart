import 'package:boombox/common/constants.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/material.dart';

class SelectedSongsWidget extends StatelessWidget {
  final int count;

  const SelectedSongsWidget({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorHelper.lighten(
        Theme.of(context).colorScheme.secondary,
        70,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium!.merge(
                  TextStyle(
                    fontFamily: FontFamily.PRIMARY,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
          ),
          const SizedBox(width: 10),
          Text(
            'songs selected',
            style: Theme.of(context).textTheme.titleMedium!.merge(
                  const TextStyle(
                    fontFamily: FontFamily.PRIMARY,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
