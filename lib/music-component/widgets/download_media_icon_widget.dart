import 'package:boombox/common/extensions.dart';
import 'package:boombox/music-component/models/enums/download_action_enum.dart';
import 'package:flutter/material.dart';

class DownloadMediaIconWidget extends StatefulWidget {
  final void Function(DownloadAction action) onDownloadActionSelected;

  const DownloadMediaIconWidget({
    super.key,
    required this.onDownloadActionSelected,
  });

  @override
  State<StatefulWidget> createState() => _DownloadMediaIconWidget();
}

class _DownloadMediaIconWidget extends State<DownloadMediaIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;
  late DownloadAction _action;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() => setState(() {}));
    _animation = ColorTween(begin: Colors.black, end: Colors.black).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _alignAnimation();
        setState(() {});
      },
    );

    _action = DownloadAction.none;
  }

  @override
  void dispose() {
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onDownloadActionToggle(),
      onLongPress: () => _onDownloadActionLongPressed(),
      child: ImageIcon(
        const ResizeImage(
          AssetImage('assets/images/download.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
        color: _animation.value,
        size: 32,
      ),
    );
  }

  void _onDownloadActionToggle() {
    _controller.duration = const Duration(milliseconds: 250);
    if (_action.equals(DownloadAction.none)) {
      _action = DownloadAction.later;
      _controller.forward();
      widget.onDownloadActionSelected(_action);
    } else {
      _action = DownloadAction.none;
      _controller.reverse();
      widget.onDownloadActionSelected(_action);
    }
  }

  void _onDownloadActionLongPressed() {
    if (_action.equals(DownloadAction.now)) return;
    _action = DownloadAction.now;
    _controller.duration = const Duration(milliseconds: 500);
    _controller.repeat(reverse: true);
    widget.onDownloadActionSelected(_action);
  }

  void _alignAnimation() {
    _animation = ColorTween(
            begin: Theme.of(context).iconTheme.color,
            end: Theme.of(context).colorScheme.primary)
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}
