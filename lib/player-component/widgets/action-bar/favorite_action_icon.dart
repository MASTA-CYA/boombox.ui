import 'package:boombox/common/debouncer.dart';
import 'package:boombox/favorites-component/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteActionIconWidget extends StatefulWidget {
  const FavoriteActionIconWidget({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteActionIconWidget();
}

class _FavoriteActionIconWidget extends State<FavoriteActionIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Debouncer _debouncer;

  bool _isFavorite = false;

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
      stream: Provider.of<FavoritesService>(context).getIsFavoriteStream,
      builder: (context, snapshot) {
        _isFavorite = snapshot.data ?? false;
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<FavoritesService>(
              context,
              listen: false,
            ).isFavoriteAsync(),
            builder: (context, snapshot) => GestureDetector(
              child: AnimatedScale(
                duration: const Duration(seconds: 5),
                scale: _scaleAnimation.value,
                curve: Curves.easeInOut,
                child: ImageIcon(
                  const ResizeImage(
                    AssetImage('assets/images/fire.png'),
                    width: 70,
                    height: 70,
                    allowUpscaling: true,
                  ),
                  color: snapshot.data ?? false
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color,
                ),
              ),
              onTap: () async => await _onFavoritePressed(),
            ),
          );
        } else {
          return GestureDetector(
            child: AnimatedScale(
              duration: const Duration(seconds: 5),
              scale: _scaleAnimation.value,
              curve: Curves.easeInOut,
              child: ImageIcon(
                const ResizeImage(
                  AssetImage('assets/images/fire.png'),
                  width: 70,
                  height: 70,
                  allowUpscaling: true,
                ),
                color: _isFavorite
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
            ),
            onTap: () async => await _onFavoritePressed(),
          );
        }
      },
    );
  }

  Future<void> _onFavoritePressed() async {
    await Provider.of<FavoritesService>(
      context,
      listen: false,
    ).addOrRemovedFavoriteAsync();
    await _controller.forward();
    _debouncer.run((_) async => await _controller.reverse());
  }
}
