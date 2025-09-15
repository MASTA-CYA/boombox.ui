import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/widgets/playing_icon.dart';
import 'package:flutter/material.dart';

class PopupMiniPlayerWidget extends StatefulWidget {
  final TrackInfo song;
  final void Function(bool shouldHide)? onShouldHidePressed;
  final void Function()? onNavigatorToPlayerPressed;
  final void Function(bool isPlaying)? onPlayPausePressed;
  final void Function(bool isPlaying)? onPlayerStateChanged;

  const PopupMiniPlayerWidget({
    super.key,
    required this.song,
    this.onShouldHidePressed,
    this.onNavigatorToPlayerPressed,
    this.onPlayPausePressed,
    this.onPlayerStateChanged,
  });

  @override
  State<PopupMiniPlayerWidget> createState() => _PopupMiniPlayerWidgetState();
}

class _PopupMiniPlayerWidgetState extends State<PopupMiniPlayerWidget> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.light
          ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onNavigatorToPlayerPressed ??
                () => widget.onNavigatorToPlayerPressed!(),
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 8, 18, 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 50,
                  maxWidth: 50,
                ),
                child: Hero(
                  tag: 'ALBUM_ART',
                  child: widget.song.art!.isNotEmpty
                      ? Image.memory(widget.song.art!)
                      : Image.asset(
                          'assets/images/cd.png',
                          color: Theme.of(context)
                                  .brightness
                                  .equals(Brightness.dark)
                              ? Colors.white
                              : Colors.black,
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(widget.song.title!),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _onPlayPausePressed(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: PlayingIconWidget(
                useRandomPattern: false,
                onPlayerStateChanged: (isPlaying) =>
                    _onPlayerStateChanged(isPlaying),
              ),
            ),
          ),
          if (!widget.onShouldHidePressed.isNull)
            IconButton(
              onPressed: () => widget.onShouldHidePressed!(true),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
        ],
      ),
    );
  }

  void _onPlayerStateChanged(bool isPlaying) {
    _isPlaying = isPlaying;
    if (!widget.onPlayerStateChanged.isNull) {
      widget.onPlayerStateChanged!(_isPlaying);
    }
  }

  void _onPlayPausePressed() {
    if (!widget.onPlayPausePressed.isNull) {
      widget.onPlayPausePressed!(_isPlaying);
    }
  }
}
