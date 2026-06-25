import 'package:boombox/player-component/models/enums/player_mode_enum.dart';
import 'package:boombox/player-component/models/enums/player_state_enum.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/player_mode_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerButtonsWidget extends StatefulWidget {
  final String sender;
  final void Function(PlayerMode mode) onPlayerModeChanged;
  final void Function() onPreviousTrackPressed;
  final void Function(PlayerState state) onPlayerStateChanged;
  final void Function() onNextTrackPressed;
  final void Function() onPlaylistPressed;

  const PlayerButtonsWidget({
    super.key,
    required this.sender,
    required this.onPlayerModeChanged,
    required this.onPreviousTrackPressed,
    required this.onPlayerStateChanged,
    required this.onNextTrackPressed,
    required this.onPlaylistPressed,
  });

  @override
  State<StatefulWidget> createState() => _PlayerButtonsWidget();
}

class _PlayerButtonsWidget extends State<PlayerButtonsWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.reset();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PlayerModeIconWidget(
          onModeChanged: (mode) => widget.onPlayerModeChanged(mode),
        ),
        _buildPlayerButtons(),
        _buildPlaylistButton(),
      ],
    );
  }

  Widget _buildPlayerButtons() {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getSequenceStateStream,
      builder: (context, snapshot) {
        bool hasPrevious = true;
        bool hasNext = true;
        if (snapshot.hasData && snapshot.data!.sequence.isNotEmpty) {
          hasPrevious = snapshot.data!.sequence.length > 1;
          hasNext =
              snapshot.data!.currentIndex! < snapshot.data!.sequence.length &&
                  hasPrevious;
        }

        return Row(
          children: [
            _buildPreviousButton(hasPrevious),
            _buildPlayPauseButton(),
            _buildNextButton(hasNext),
          ],
        );
      },
    );
  }

  Widget _buildPreviousButton(bool hasPrevious) {
    return IconButton(
      icon: const Icon(
        Icons.skip_previous,
      ),
      iconSize: 28,
      onPressed: hasPrevious ? widget.onPreviousTrackPressed : null,
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context)
          .getPlayerPlayingStateStream(widget.sender),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Sync with animation player
          if (snapshot.data! && !_controller.isCompleted) {
            _controller.forward();
          } else if (!snapshot.data! && _controller.isCompleted) {
            _controller.reverse();
          }
        }

        return IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.pause_play,
            color: Theme.of(context).primaryColor,
            progress: _animation,
          ),
          iconSize: 60,
          onPressed: () async => _onPlayButtonPressed(),
        );
      },
    );
  }

  Widget _buildNextButton(bool hasNext) {
    return IconButton(
      icon: const Icon(
        Icons.skip_next,
      ),
      iconSize: 28,
      onPressed: hasNext ? widget.onNextTrackPressed : null,
    );
  }

  Widget _buildPlaylistButton() {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      child: IconButton(
        icon: const ImageIcon(
          ResizeImage(
            AssetImage('assets/images/playlist-1.png'),
            width: 70,
            height: 70,
            allowUpscaling: false,
          ),
          size: 17,
        ),
        onPressed: widget.onPlaylistPressed,
      ),
    );
  }

  void _onPlayButtonPressed() async {
    _controller.status == AnimationStatus.completed
        ? widget.onPlayerStateChanged(PlayerState.paused)
        : widget.onPlayerStateChanged(PlayerState.playing);
  }
}
