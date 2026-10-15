import 'package:boombox/music-component/music_barrel.dart';
import 'package:boombox/player-component/models/enums/player_mode_enum.dart';
import 'package:boombox/player-component/models/enums/player_state_enum.dart';
import 'package:boombox/player-component/services/trim_audio_service.dart';

class PlayerFunctionsHelper {
  static final PlayerFunctionsHelper _instance =
      PlayerFunctionsHelper._internal();
// using a factory is important
// because it promises to return _an_ object of this type
  factory PlayerFunctionsHelper() {
    return _instance;
  }
// This named constructor is the "real" constructor
// It'll be called exactly once, by the static property assignment above
// it's also private, so it can only be called in this class
  PlayerFunctionsHelper._internal() {}

  Future<void> onPlayerModeChangedAsync(
    BuildContext context,
    PlayerMode mode,
  ) async {
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).setPlayerModeAsync(mode);
  }

  Future<void> onPreviousTrackPressedAsync(BuildContext context) async {
    if (!context.mounted) return;
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).previousAsync();
  }

  Future<void> onPlayerStateChangedAsync(
    BuildContext context,
    PlayerState state,
  ) async {
    if (!context.mounted) return;
    state == PlayerState.playing
        ? await Provider.of<PlayerService>(context, listen: false).playAsync()
        : await Provider.of<PlayerService>(context, listen: false).pauseAsync();
  }

  Future<void> onNextTrackPressedAsync(BuildContext context) async {
    if (!context.mounted) return;
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).nextAsync();
  }

  Future<void> onPlaylistSongSelectedAsync(
    BuildContext context,
    bool isPlaying,
    String path,
  ) async {
    if (!context.mounted) return;
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).playSelectedPlaylistSongAsync(path, isPlaying);
  }

  Future<void> onSeekBarPositionChangedAsync(
    BuildContext context,
    Duration duration,
  ) async {
    if (!context.mounted) return;
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).seekAsync(duration);
  }

  Future<void> onSeekBarRangeChangedAsync(
    BuildContext context,
    List<Duration?> range,
  ) async {
    if (!context.mounted) return;

    await Provider.of<TrimAudioService>(
      context,
      listen: false,
    ).addAudioTrimDataAsync(
      start: range.first,
      end: range.last,
    );
  }
}
