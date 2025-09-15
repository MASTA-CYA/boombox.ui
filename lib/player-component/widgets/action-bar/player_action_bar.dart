import 'package:boombox/player-component/widgets/action-bar/favorite_action_icon.dart';
import 'package:boombox/player-component/widgets/action-bar/info_action_icon.dart';
import 'package:boombox/player-component/widgets/action-bar/lyrics_action_icon.dart';
import 'package:boombox/player-component/widgets/action-bar/trim_action_icon.dart';
import 'package:flutter/material.dart';

class PlayerActionBarWidget extends StatefulWidget {
  final VoidCallback onInfoPressed;
  final VoidCallback onLyricsPressed;
  final Function(bool isActive) onTrimActivePressed;

  const PlayerActionBarWidget({
    super.key,
    required this.onInfoPressed,
    required this.onLyricsPressed,
    required this.onTrimActivePressed,
  });

  @override
  State<PlayerActionBarWidget> createState() => _PlayerActionBarWidgetState();
}

class _PlayerActionBarWidgetState extends State<PlayerActionBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _lyricsAnimation;
  late Animation<Offset> _favoriteAnimation;
  late Animation<Offset> _infoAnimation;

  bool _isInfoSelected = false;
  bool _isLyricsSelected = false;

  final ValueNotifier<int> _actionRedrawCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );

    _lyricsAnimation = Tween(
      begin: const Offset(-4.2, 0.0),
      end: Offset.zero,
    ).animate(curve);
    _favoriteAnimation = Tween(
      begin: const Offset(0.0, -0.6),
      end: Offset.zero,
    ).animate(curve);
    _infoAnimation = Tween(
      begin: const Offset(4.2, 0.0),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoIcon(),
          _buildFavoriteIcon(),
          _buildTrimIcon(),
          _buildLyricsIcon(),
        ],
      ),
    );
  }

  Widget _buildInfoIcon() {
    return ValueListenableBuilder(
      valueListenable: _actionRedrawCount,
      builder: (context, value, child) => SlideTransition(
        position: _infoAnimation,
        child: InfoActionIconWidget(
          key: UniqueKey(),
          isSelected: _isInfoSelected,
          isLyricsSelected: _isLyricsSelected,
          onInfoPressed: () => _onInfoPressed(),
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon() {
    return SlideTransition(
      position: _favoriteAnimation,
      child: const FavoriteActionIconWidget(),
    );
  }

  Widget _buildTrimIcon() {
    return SlideTransition(
      position: _favoriteAnimation,
      child: TrimActionIconWidget(
        onTrimActivePressed: (isActive) async =>
            await _onTrimActivePressed(isActive),
      ),
    );
  }

  Widget _buildLyricsIcon() {
    return ValueListenableBuilder(
      valueListenable: _actionRedrawCount,
      builder: (context, value, child) => SlideTransition(
        position: _lyricsAnimation,
        child: LyricsActionIconWidget(
          key: UniqueKey(),
          isSelected: _isLyricsSelected,
          isInfoSelected: _isInfoSelected,
          onLyricsPressed: _onLyricsPressed,
        ),
      ),
    );
  }

  void _onInfoPressed() {
    if (!_isLyricsSelected) {
      widget.onInfoPressed();
      _isInfoSelected = !_isInfoSelected;
      _actionRedrawCount.value = _actionRedrawCount.value++;
    }
  }

  void _onLyricsPressed() {
    if (!_isInfoSelected) {
      widget.onLyricsPressed();
      _isLyricsSelected = !_isLyricsSelected;
      _actionRedrawCount.value = _actionRedrawCount.value++;
    }
  }

  Future<void> _onTrimActivePressed(bool isActive) async {
    await widget.onTrimActivePressed(isActive);
  }
}
