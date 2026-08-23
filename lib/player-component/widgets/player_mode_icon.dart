import 'package:boombox/player-component/models/enums/player_mode_enum.dart';
import 'package:flutter/material.dart';

class PlayerModeIconWidget extends StatefulWidget {
  final void Function(PlayerMode mode) onModeChanged;

  const PlayerModeIconWidget({
    super.key,
    required this.onModeChanged,
  });

  @override
  State<PlayerModeIconWidget> createState() => _PlayerModeIconWidgetState();
}

class _PlayerModeIconWidgetState extends State<PlayerModeIconWidget> {
  final ValueNotifier<PlayerMode> _selectedMode =
      ValueNotifier<PlayerMode>(PlayerMode.playOnce);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _selectedMode,
      builder: (context, mode, child) => AnimatedSwitcher(
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        duration: const Duration(milliseconds: 250),
        child: IconButton(
          key: UniqueKey(),
          onPressed: () => _onModeChanged(),
          icon: ImageIcon(
            ResizeImage(
              AssetImage('assets/images/${_getIconImageName(mode)}.png'),
              width: 70,
              height: 70,
              allowUpscaling: false,
            ),
            size: 25,
          ),
        ),
      ),
    );
  }

  void _onModeChanged() async {
    _selectedMode.value = PlayerMode.values.elementAt(
      _getSelectedModeIndex(),
    );
    widget.onModeChanged(_selectedMode.value);
    // setState(() {});
  }

  int _getSelectedModeIndex() {
    PlayerMode currentMode = _selectedMode.value;
    return currentMode.index == PlayerMode.values.length - 1
        ? 0
        : currentMode.index + 1;
  }

  String _getIconImageName(PlayerMode mode) {
    String image = '';

    switch (mode) {
      case PlayerMode.playOnce:
        image = 'play-once';
        break;
      case PlayerMode.repeatAll:
        image = 'repeat-all';
        break;
      case PlayerMode.repeatOne:
        image = 'repeat-one';
        break;
      case PlayerMode.shuffle:
        image = 'shuffle';
        break;
    }

    return image;
  }
}
