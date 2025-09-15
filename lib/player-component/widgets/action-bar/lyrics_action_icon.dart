import 'package:flutter/material.dart';

class LyricsActionIconWidget extends StatefulWidget {
  final bool isSelected;
  final bool isInfoSelected;
  final VoidCallback onLyricsPressed;

  const LyricsActionIconWidget({
    super.key,
    required this.isSelected,
    required this.isInfoSelected,
    required this.onLyricsPressed,
  });

  @override
  State<StatefulWidget> createState() => _LyricsActionIconWidget();
}

class _LyricsActionIconWidget extends State<LyricsActionIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isInfoSelected ? 250 : 500),
    )..addListener(() => setState(() {}));
    _animation = ColorTween(begin: Colors.black, end: Colors.black).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _alignAnimation());
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
      onTap: widget.onLyricsPressed,
      child: ImageIcon(
        const ResizeImage(
          AssetImage('assets/images/lyrics.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
        color: _animation.value!,
      ),
    );
  }

  void _alignAnimation() {
    _animation = ColorTween(
      begin: Theme.of(context).iconTheme.color,
      end: widget.isInfoSelected
          ? Theme.of(context).colorScheme.secondary
          : widget.isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).iconTheme.color,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.isInfoSelected ? Curves.linear : Curves.bounceOut,
      ),
    );
    _controller.forward();
  }
}
