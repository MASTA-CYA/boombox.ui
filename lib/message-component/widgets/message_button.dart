import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:boombox/common/helpers/color_helper.dart' as colorHelper;

class MessageButtonWidget extends StatelessWidget {
  final Widget icon;
  final String text;
  final Color? color;
  final bool? isPrimary;
  final VoidCallback onPressed;

  const MessageButtonWidget({
    Key? key,
    required this.icon,
    required this.text,
    this.color,
    this.isPrimary = true,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary!
            ? Theme.of(context)
                .elevatedButtonTheme
                .style
                ?.backgroundColor
                ?.resolve({MaterialState.pressed})
            : Theme.of(context).colorScheme.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: color ??
            (isPrimary! ? Colors.white : Theme.of(context).primaryColor),
        shape: StadiumBorder(
          side: BorderSide(color: color ?? Theme.of(context).primaryColor),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
      ),
      icon: icon,
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: FontFamily.PRIMARY,
          fontSize: 18,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
