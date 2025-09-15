import 'package:flutter/material.dart';

class BottomSheetModalWidget extends StatelessWidget {
  final Widget child;

  const BottomSheetModalWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopNotch(context),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildTopNotch(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 100,
        height: 6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
