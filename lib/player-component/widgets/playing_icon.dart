import 'dart:math';

import 'package:boombox/common/extensions.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayingIconWidget extends StatefulWidget {
  final bool? useRandomPattern;
  final Function(bool isPlaying)? onPlayerStateChanged;

  const PlayingIconWidget({
    super.key,
    this.useRandomPattern = true,
    this.onPlayerStateChanged,
  });

  @override
  State<StatefulWidget> createState() => _PlayingIconWidget();
}

class _PlayingIconWidget extends State<PlayingIconWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _colorAnimation;
  late List<Animation> _scaleAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() => setState(() {}));
    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.black,
    ).animate(_controller);

    if (widget.useRandomPattern!) {
      _scaleAnimations = [];
      for (var i = 0; i < 5; i++) {
        final double begin = Random().nextDouble();
        final double end = Random().nextDouble();

        _scaleAnimations.add(
          Tween(begin: begin, end: end).animate(_controller),
        );
      }
    } else {
      _scaleAnimations = [
        Tween(
          begin: 0.9265148654188092,
          end: 0.6916767228679245,
        ).animate(_controller),
        Tween(
          begin: 0.22689917598595133,
          end: 0.2689352467626699,
        ).animate(_controller),
        Tween(
          begin: 0.20854504399273688,
          end: 0.8247501584926455,
        ).animate(_controller),
        Tween(
          begin: 0.11498296886913484,
          end: 0.4432080000606021,
        ).animate(_controller),
        Tween(
          begin: 0.5994239520283218,
          end: 0.4996350279802848,
        ).animate(_controller),
      ];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _alignAnimation();
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
    return StreamBuilder(
      stream: Provider.of<PlayerService>(
        context,
      ).getPlayerPlayingStateStream('POPUP'),
      builder: (context, snapshot) {
        if (snapshot.hasData) _manageControllerState(snapshot.data!);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: _scaleAnimations.map((e) => _buildWaveBar(e)).toList(),
        );
      },
    );
  }

  Widget _buildWaveBar(Animation animation) {
    return Transform.scale(
      scale: animation.value,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        width: 2.5,
        height: 30,
        decoration: BoxDecoration(
          color: _colorAnimation.value,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary,
              blurRadius: 2,
              offset: Offset.zero,
            ),
          ],
        ),
      ),
    );
  }

  void _alignAnimation() {
    _colorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.secondary,
      end: Theme.of(context).colorScheme.primary,
    ).animate(_controller);
  }

  void _manageControllerState(bool isPlaying) {
    if (isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!isPlaying) {
      _controller.stop();
    }

    // Notify parent
    if (!widget.onPlayerStateChanged.isNull) {
      widget.onPlayerStateChanged!(isPlaying);
    }
  }
}
