import 'package:boombox/common/constants.dart';
import 'package:boombox/common/debouncer.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/player-component/models/enums/playlist_mode_enum.dart';
import 'package:flutter/material.dart';

class PlaylistHeaderControlsWidget extends StatefulWidget {
  final String name;
  final void Function(PlaylistMode mode) onPlaylistModeChanged;
  final void Function() onPlaylistSweepPressed;
  final void Function() onSavePlaylistPressed;

  const PlaylistHeaderControlsWidget({
    super.key,
    required this.name,
    required this.onPlaylistModeChanged,
    required this.onPlaylistSweepPressed,
    required this.onSavePlaylistPressed,
  });

  @override
  State<StatefulWidget> createState() => _PlaylistHeaderControlsWidget();
}

class _PlaylistHeaderControlsWidget extends State<PlaylistHeaderControlsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Debouncer _debouncer;

  late PlaylistMode _mode;
  late bool _hasDebouncerCompleted;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration());
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _debouncer = Debouncer(milliseconds: 4000);
    _mode = PlaylistMode.simple;
    _hasDebouncerCompleted = true;
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 4, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlaylistName(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSwapIcon(),
                  _buildSweepIcon(),
                  _buildSaveIcon(),
                ],
              ),
            ],
          ),
        ),
        _buildSwapModePopUp(),
      ],
    );
  }

  Widget _buildPlaylistName() {
    return Text(
      widget.name,
      style: Theme.of(context).textTheme.bodyMedium?.merge(
            const TextStyle(
              fontFamily: FontFamily.PRIMARY,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }

  Widget _buildSwapIcon() {
    return IconButton(
      icon: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/swap.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      onPressed: () async => _onPlaylistModeChangedPressed(),
    );
  }

  Widget _buildSweepIcon() {
    return IconButton(
      icon: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/broom.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      onPressed: widget.onPlaylistSweepPressed,
    );
  }

  Widget _buildSaveIcon() {
    return IconButton(
      icon: const Icon(Icons.save),
      onPressed: widget.onSavePlaylistPressed,
    );
  }

  Widget _buildSwapModePopUp() {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 10),
      reverseDuration: const Duration(seconds: 10),
      child: _hasDebouncerCompleted
          ? SizedBox.shrink(key: UniqueKey())
          : Row(
              key: UniqueKey(),
              children: [
                Expanded(
                  child: _buildSwapMode(),
                ),
              ],
            ),
    );
  }

  Widget _buildSwapMode() {
    return AnimatedOpacity(
      opacity: _animation.value,
      duration: const Duration(seconds: 5),
      curve: Curves.fastOutSlowIn,
      child: Container(
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.secondary),
        child: Text(
          '${_mode.name.capitalize()} Mode',
        ),
      ),
    );
  }

  void _onPlaylistModeChangedPressed() async {
    _mode = _mode.index == 0 ? PlaylistMode.simple : PlaylistMode.reorder;
    _hasDebouncerCompleted = false;
    widget.onPlaylistModeChanged(_mode);
    await _controller.forward();
    setState(() {});
    _debouncer.run(
      (_) async {
        await _controller.reverse();
        _hasDebouncerCompleted = true;
        setState(() {});
      },
    );
  }
}
