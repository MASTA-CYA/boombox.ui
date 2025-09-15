import 'package:boombox/common/constants.dart';
import 'package:boombox/common/navigator/navigator_button.dart';
import 'package:flutter/material.dart';

class UnknownRouteWidget extends StatefulWidget {
  const UnknownRouteWidget({super.key});

  @override
  State<UnknownRouteWidget> createState() => _UnknownRouteWidgetState();
}

class _UnknownRouteWidgetState extends State<UnknownRouteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = ColorTween(
      begin: Colors.black,
      end: Colors.black,
    ).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _animation = ColorTween(
          begin: Theme.of(context).iconTheme.color,
          end: Colors.red,
        ).animate(_controller)
          ..addListener(() => setState(() {}));
        await _controller.repeat(reverse: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 150),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          height: 180,
          child: ImageIcon(
            const ResizeImage(
              AssetImage('assets/images/broken.png'),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 180,
            color: _animation.value,
          ),
        ),
        Text(
          'INVALID PAGE ROUTE',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'There was an issue with finding the '
              'right page to navigate to/from.',
              style: Theme.of(context).textTheme.titleMedium?.merge(
                    const TextStyle(),
                  ),
            ),
          ),
        ),
        const Spacer(),
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: NavigatorButtonWidget(
            isPrimary: true,
            text: 'Report Issue',
            onPressed: () {},
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
