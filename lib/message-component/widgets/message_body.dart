import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MessageBodyWidget extends StatelessWidget {
  final String body;

  MessageBodyWidget({
    super.key,
    required this.body,
  });

  BorderSide? _borderSide;

  @override
  Widget build(BuildContext context) {
    _borderSide = BorderSide(
      color: Theme.of(context).brightness == Brightness.light
          ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      width: 5,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: _borderSide!,
          right: _borderSide!,
          bottom: _borderSide!,
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.all(6),
              child: Text(body),
            ),
          ),
        ],
      ),
    );
  }
}
