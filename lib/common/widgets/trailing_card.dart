import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/material.dart';

class TrailingCardWidget extends StatelessWidget {
  final Widget child;

  const TrailingCardWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary,
            blurRadius: 5,
            offset: Offset.zero,
          ),
        ],
      ),
      child: child,
    );
  }
}
