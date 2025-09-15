import 'package:boombox/common/constants.dart';
import 'package:boombox/music-component/models/music_category_filter_model.dart';
import 'package:flutter/material.dart';

class MusicCategoryWidget extends StatefulWidget {
  final MusicCategoryFilter category;
  final Function(String category) onCategorySelected;

  const MusicCategoryWidget({
    super.key,
    required this.category,
    required this.onCategorySelected,
  });

  @override
  State<StatefulWidget> createState() => _CatalogueCategoryWidget();
}

class _CatalogueCategoryWidget extends State<MusicCategoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = ColorTween(begin: Colors.black, end: Colors.black)
        .animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _alignAnimation();
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _alignAnimation();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                widget.category.text,
                style: Theme.of(context).textTheme.bodyLarge?.merge(
                      TextStyle(
                        fontFamily: FontFamily.PRIMARY,
                        color: _animation.value,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            Container(
              height: 4,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: _animation.value,
              ),
            ),
          ],
        ),
        onTap: () => onCategorySelected(widget.category.text),
      ),
    );
  }

  void onCategorySelected(String category) async {
    widget.onCategorySelected(category);
    _animationController.status == AnimationStatus.completed
        ? await _animationController.reverse()
        : await _animationController.forward();
    setState(() {});
  }

  void _alignAnimation() {
    _animationController.reset();
    if (widget.category.isSelected!) {
      _animation = ColorTween(
        begin: Theme.of(context).primaryColor,
        end: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ).animate(_animationController);
    } else {
      _animation = ColorTween(
              begin: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              end: Theme.of(context).primaryColor)
          .animate(_animationController);
    }
  }
}
