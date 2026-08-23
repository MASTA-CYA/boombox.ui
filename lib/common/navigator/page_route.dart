import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:flutter/material.dart';

class AnimatedMaterialPageRoute<T> extends PageRoute {
  final Widget widget;
  final Color transitionColor;
  final bool isNavigatingForward;
  final TransitionDirection direction;

  AnimatedMaterialPageRoute({
    required this.widget,
    required this.transitionColor,
    this.isNavigatingForward = true,
    this.direction = TransitionDirection.ltr,
    settings,
  }) : super(settings: settings ?? const RouteSettings());

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    if (settings.name?.equals('/') ?? false) return this.widget;

    Offset begin = direction.offset;
    const Offset end = Offset(0.0, 0.0);
    Curve curve = Curves.easeIn;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: widget,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color? get barrierColor => transitionColor;

  @override
  String? get barrierLabel => null;
}
