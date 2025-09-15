import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    this.onPressed,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.primary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}