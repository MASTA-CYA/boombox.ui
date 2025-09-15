import 'package:boombox/common/debouncer.dart';
import 'package:boombox/player-component/services/trim_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrimActionIconWidget extends StatefulWidget {
  final Function(bool isActive) onTrimActivePressed;

  const TrimActionIconWidget({
    super.key,
    required this.onTrimActivePressed,
  });

  @override
  State<StatefulWidget> createState() => _TrimActionIconWidget();
}

class _TrimActionIconWidget extends State<TrimActionIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Debouncer _debouncer;

  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration());
    _scaleAnimation = Tween(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() => setState(() {}));
    _debouncer = Debouncer(milliseconds: 200);
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
      stream: Provider.of<TrimAudioService>(context).getClipModeStream,
      builder: (context, snapshot) {
        _isActive = snapshot.hasData && snapshot.data!;
        if (!_isActive) {
          return FutureBuilder(
            future: Provider.of<TrimAudioService>(
              context,
              listen: false,
            ).getClipModeAsync(),
            builder: (context, snapshot) {
              _isActive = snapshot.hasData && snapshot.data!;

              return GestureDetector(
                child: AnimatedScale(
                  duration: const Duration(seconds: 5),
                  scale: _scaleAnimation.value,
                  curve: Curves.easeInOut,
                  child: ImageIcon(
                    const ResizeImage(
                      AssetImage('assets/images/cut.png'),
                      width: 70,
                      height: 70,
                      allowUpscaling: true,
                    ),
                    color: _isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                onTap: () async => await _onTrimAudioPressed(!_isActive),
              );
            },
          );
        } else {
          return GestureDetector(
            child: AnimatedScale(
              duration: const Duration(seconds: 5),
              scale: _scaleAnimation.value,
              curve: Curves.easeInOut,
              child: ImageIcon(
                const ResizeImage(
                  AssetImage('assets/images/cut.png'),
                  width: 70,
                  height: 70,
                  allowUpscaling: true,
                ),
                color: _isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
            ),
            onTap: () async => await _onTrimAudioPressed(!_isActive),
          );
        }
      },
    );
  }

  Future<void> _onTrimAudioPressed(bool isActive) async {
    await Provider.of<TrimAudioService>(
      context,
      listen: false,
    ).setClipModeAsync(isActive);
    await widget.onTrimActivePressed(isActive);
    await _controller.forward();
    _debouncer.run((_) async => await _controller.reverse());
  }
}
