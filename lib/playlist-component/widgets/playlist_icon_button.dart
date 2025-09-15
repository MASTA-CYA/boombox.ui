import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:boombox/common/helpers/color_helper.dart' as colorHelper;

class PlaylistIconButtonWidget extends StatelessWidget {
  final Widget icon;
  final Color? color;
  final bool? isPrimary;
  final VoidCallback onClicked;

  const PlaylistIconButtonWidget({
    Key? key,
    required this.icon,
    this.color,
    this.isPrimary = true,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary!
            ? Theme.of(context)
                .elevatedButtonTheme
                .style
                ?.backgroundColor
                ?.resolve({MaterialState.pressed})
            : Theme.of(context).cardTheme.color,
        surfaceTintColor: Colors.transparent,
        foregroundColor: color ??
            (isPrimary! ? Colors.white : Theme.of(context).primaryColor),
        shape: const CircleBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 6,
        ),
      ),
      onPressed: onClicked,
      child: icon,
    );
  }
}
