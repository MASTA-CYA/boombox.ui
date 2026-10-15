import 'package:boombox/player-component/widgets/action-bar/track_info.dart';
import 'package:flutter/material.dart';

class ActionContainerWidget<T> extends StatelessWidget {
  final Widget child;

  const ActionContainerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
          colors: _buildGradientColors(context),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          width: 4,
          color: Theme.of(context).colorScheme.secondary,
        ),
        backgroundBlendMode: BlendMode.difference,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: child,
        ),
      ),
    );
  }

  List<Color> _buildGradientColors(BuildContext context) {
    return T == TrackInfoWidget
        ? <Color>[
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.background,
            Theme.of(context).colorScheme.primary,
          ]
        : <Color>[
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.background,
            Theme.of(context).colorScheme.primary,
          ];
  }
}
