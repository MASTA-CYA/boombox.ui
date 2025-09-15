import 'package:flutter/material.dart';

class CircularProgressIndicatorWidget extends StatefulWidget {
  final bool useIcon;
  const CircularProgressIndicatorWidget({
    super.key,
    this.useIcon = false,
  });

  @override
  State<StatefulWidget> createState() => _CircularProgressIndicatorWidget();
}

class _CircularProgressIndicatorWidget
    extends State<CircularProgressIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool determinate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )
      ..repeat(reverse: true)
      ..addListener(() {
        setState(() {});
      });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (widget.useIcon) {
          _controller.stop();
          _controller.dispose();
          _controller = AnimationController(
            vsync: this,
            duration: const Duration(
              seconds: 1,
              milliseconds: 500,
            ),
          )
            ..repeat(reverse: true)
            ..addListener(
              () {
                setState(() {});
              },
            );

          _animation = CurvedAnimation(
            parent: _controller,
            curve: Curves.linear,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.useIcon
          ? RotationTransition(
              turns: _animation,
              child: Container(
                key: UniqueKey(),
                width: 70,
                height: 70,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: ResizeImage(
                      AssetImage('assets/images/yarn-launcher.png'),
                      width: 1000,
                      height: 1000,
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            )
          : CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              value: _controller.value,
            ),
    );
  }
}
