import 'package:flutter/material.dart';

class FilledWidget extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? disabledColor;
  final int percent;

  const FilledWidget({
    super.key,
    required this.child,
    required this.color,
    this.disabledColor,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    Color defaultIconColor = Theme.of(context).iconTheme.color!;
    Color disabledIconColor = disabledColor ?? Theme.of(context).colorScheme.secondary;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect rect) {
        return LinearGradient(
          stops: [
            0,
            percent / 100,
            percent / 100,
          ],
          colors: [
            color ?? defaultIconColor,
            color ?? defaultIconColor,
            disabledIconColor,
          ],
        ).createShader(rect);
      },
      child: child,
    );
  }
}
