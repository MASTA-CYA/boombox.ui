import 'package:audio_service/audio_service.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/image-store/image_store_service.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/application_lifecycle_service.dart';
import 'package:boombox/common/services/notification_service.dart';
import 'package:boombox/music-component/music_barrel.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class MediaControlsHandler extends BaseAudioHandler {
  late bool _isPlaying;

  static final MediaControlsHandler _instance =
      MediaControlsHandler._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory MediaControlsHandler() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  MediaControlsHandler._internal() {
    _isPlaying = false;

    PlayerService().getPlayerPlayingStateStream('MEDIA')?.listen(
          (isPlaying) => _isPlaying = isPlaying,
        );
    PlayerService().getSequenceStateStream.listen(
        (sequence) async => await _updateMediaItemListenersAsync(sequence));
    PlayerService().getPlaybackStateStream.listen(
      (state) {
        final PlaybackState playback = PlaybackState(
          processingState: _getAudioProcessingState(state.processingState),
          updateTime: state.updateTime,
          updatePosition: state.updatePosition,
          bufferedPosition: state.bufferedPosition,
          controls: [
            MediaControl.play,
            MediaControl.pause,
            MediaControl.skipToNext,
            MediaControl.skipToPrevious,
          ],
          playing: _isPlaying,
        );
        _instance.playbackState.add(playback);
      },
    );
  }

  @override
  Future<void> play() async => await PlayerService().playAsync();

  @override
  Future<void> pause() async => await PlayerService().pauseAsync();

  @override
  Future<void> stop() async => await PlayerService().stopAsync();

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    switch (button) {
      case MediaButton.media:
        _isPlaying
            ? await PlayerService().pauseAsync()
            : await PlayerService().playAsync();
        break;
      case MediaButton.next:
        await PlayerService().nextAsync();
        break;
      case MediaButton.previous:
        await PlayerService().previousAsync();
        break;
    }

    Logger.logAsync(
      LogEvent<MediaControlsHandler>(
        severity: Severity.information,
        tag: Tag.handler,
        line: 'Click media control receiver for '
            '${describeEnum(button).toUpperCase()}',
      ),
    );
  }

  Future<void> _updateMediaItemListenersAsync(SequenceState? sequence) async {
    if (sequence.isNull) return;

    TrackInfo? info = sequence!.currentSource?.tag as TrackInfo?;
    if (info.isNull) return;

    if (sequence.sequence.length > 1) _updateQueue(sequence);

    Uri? image;
    if (info!.art!.isNotEmpty) {
      final String? path = await ImageStoreService.cacheAlbumArtAsync(
        info.title!,
        info.art!,
      );
      if (!path.isNull) image = Uri.file(path!);
    }

    final String album = MusicService().getAlbumName(info.title!) ?? 'Unknown';
    final String key = '${info.title}_$album';
    final MediaItem item = MediaItem(
      id: key,
      artUri: image,
      title: info.title!,
      album: album,
      artist: info.artist!,
      genre: info.genre,
      playable: true,
      duration:
          info.duration.isNull ? null : Duration(milliseconds: info.duration!),
      displayTitle: info.title!,
      displaySubtitle: album,
      displayDescription: info.details,
    );
    _instance.mediaItem.add(item);

    await showNowPlayingNotificationAsync(
      info,
      image: image?.path,
      isPlaying: _isPlaying,
    );
  }

  Future<void> showNowPlayingNotificationAsync(
    TrackInfo nowPlaying, {
    String? image,
    bool? isPlaying,
  }) async {
    if (ApplicationLifecycleService.canSendMediaPlayerNotifications()) {
      await NotificationService().showMediaPlayerNotification(
        nowPlaying.title ?? 'Unknown',
        nowPlaying.artist ?? 'Unknown',
        image.isNull ? 'asset://assets/images/cd.png' : 'file://$image',
        isPlaying ?? _isPlaying,
      );
    }
  }

  AudioProcessingState _getAudioProcessingState(
      ProcessingState processingState) {
    switch (processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  void _updateQueue(SequenceState sequence) async {
    List<MediaItem> queue = [];

    for (IndexedAudioSource source in sequence.sequence) {
      TrackInfo? info = source.tag as TrackInfo?;
      Uri? image;
      if (info!.art!.isNotEmpty) {
        final String? path = await ImageStoreService.cacheAlbumArtAsync(
          info.title!,
          info.art!,
        );
        if (!path.isNull) image = Uri.file(path!);
      }

      final String album =
          MusicService().getAlbumName(info.title!) ?? 'Unknown';
      final String key = '${info.title}_$album';

      queue.add(
        MediaItem(
          id: key,
          artUri: image,
          title: info.title!,
          album: album,
          artist: info.artist!,
          genre: info.genre,
          playable: true,
          duration: info.duration.isNull
              ? null
              : Duration(milliseconds: info.duration!),
          displayTitle: info.title!,
          displaySubtitle: album,
          displayDescription: info.details,
        ),
      );

      _instance.queueTitle.sink.add(
        album.equals('UNKNOWN') ? 'Now Playing' : album,
      );
    }
    _instance.queue.sink.add(queue);
  }
}
