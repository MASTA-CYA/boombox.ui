import 'package:flutter/material.dart';

class InfoActionIconWidget extends StatefulWidget {
  final bool isSelected;
  final bool isLyricsSelected;
  final VoidCallback onInfoPressed;

  const InfoActionIconWidget({
    super.key,
    required this.isSelected,
    required this.isLyricsSelected,
    required this.onInfoPressed,
  });

  @override
  State<StatefulWidget> createState() => _InfoActionIconWidget();
}

class _InfoActionIconWidget extends State<InfoActionIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isLyricsSelected ? 250 : 500),
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
    _alignAnimation();

    return GestureDetector(
      onTap: widget.onInfoPressed,
      child: ImageIcon(
        const ResizeImage(
          AssetImage('assets/images/information.png'),
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
      end: widget.isLyricsSelected
          ? Theme.of(context).colorScheme.secondary
          : widget.isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).iconTheme.color,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.isLyricsSelected ? Curves.linear : Curves.bounceOut,
      ),
    );
    _controller.forward();
  }
}
