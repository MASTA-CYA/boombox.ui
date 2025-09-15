import 'package:flutter/material.dart';

class TrailingCardWidget extends StatelessWidget {
  final Widget child;

  const TrailingCardWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: child,
      ),
    );
  }
}
