import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchIconWidget extends StatefulWidget {
  final bool isSearchOpen;
  final void Function(bool isSelected) isSearchSelected;

  const SearchIconWidget({
    super.key,
    required this.isSearchOpen,
    required this.isSearchSelected,
  });

  @override
  State<StatefulWidget> createState() => _SearchIconWidget();
}

class _SearchIconWidget extends State<SearchIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = ColorTween(
      begin: Colors.black,
      end: Colors.black,
    ).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _alignAnimation();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _alignAnimation();

    return IconButton(
      onPressed: _onSearchIconPressed,
      icon: Icon(
        CupertinoIcons.search,
        color: _animation.value,
      ),
    );
  }

  void _onSearchIconPressed() async {
    bool isSelected = _controller.status == AnimationStatus.completed;
    widget.isSearchSelected(!isSelected);
    isSelected ? await _controller.reverse() : await _controller.forward();

    setState(() {});
  }

  void _alignAnimation() async {
    _animation = ColorTween(
      begin: Theme.of(context).iconTheme.color,
      end: Theme.of(context).colorScheme.primary,
    ).animate(_controller);

    if (widget.isSearchOpen && !_controller.isCompleted) {
      await _controller.forward();
    }

    setState(() {});
  }
}
