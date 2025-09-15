import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlipWidget extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipWidget({
    super.key,
    required this.front,
    required this.back,
  });

  @override
  State<StatefulWidget> createState() => _FlipWidget();
}

class _FlipWidget extends State<FlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.rotationY(_animation.value * pi),
      alignment: Alignment.center,
      child: _isFront ? widget.front : widget.back,
    );
  }

  // Future<void> _driveAnimation() async {
  //   if (_controller.status != AnimationStatus.forward) {
  //     if (_isFront) {
  //       await _controller.forward();
  //     } else {
  //       await _controller.reverse();
  //     }

  //     _isFront = !_isFront;
  //   }
  // }
}
