import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:boombox/common/image-store/image_store_service.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/service-bus/service_bus.dart';
import 'package:boombox/common/services/application_lifecycle_service.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/notification_service.dart';
import 'package:boombox/music-component/music_barrel.dart';
import 'package:boombox/player-component/audio-handlers/media_controls_handler.dart';
import 'package:boombox/player-component/models/enums/player_mode_enum.dart';
import 'package:boombox/player-component/models/position_data_model.dart';
import 'package:boombox/player-component/models/streaming_audio_source.dart';
import 'package:boombox/player-component/services/lyrics_service.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart' as audio;
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';
import 'package:audio_decoder/audio_decoder.dart';
import 'dart:io';

class PlayerService with ChangeNotifier {
  final String _IS_PLAYING_QUEUE = '_IS_PLAYING_QUEUE';
  late Map<String, StreamController<bool>> _isPlayingSubscribers;

  late audio.AudioPlayer _player;
  // ignore: unused_field
  late AudioHandler _audioHandler;
  AudioSession? _audioSession;

  late bool _isConfigured;
  Playlist? _activePlaylist;
  String? _activeSongLyrics;
  late bool _isMiniPlayerReady;

  // Custom Streams
  late StreamController<String> _lyricsStreamController;
  Stream<String> get getLyricsStream => _lyricsStreamController.stream;

  late StreamController<Playlist> _playlistStreamController;
  Stream<Playlist> get getPlaylistStream => _playlistStreamController.stream;

  late StreamController<bool> _miniPlayerStreamController;
  Stream<bool> get getMiniPlayerStateStream =>
      _miniPlayerStreamController.stream;

  // Just_Audio streams
  Stream<int?> get getAudioSessionStream => _player.androidAudioSessionIdStream;

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get getPositionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  Stream<audio.PlayerState> get getPlayerStateStream =>
      _player.playerStateStream;
  Stream<audio.SequenceState?> get getSequenceStateStream =>
      _player.sequenceStateStream;
  // Stream<bool>? getPlayerPlayingStateStream(String sender) =>
  //     _isPlayingSubscribers[sender]?.stream;
  Stream<bool>? getPlayerPlayingStateStream(String sender) =>
      _player.playingStream;
  Stream<audio.ProcessingState> get getPlayerProcessingStateStream =>
      _player.processingStateStream;
  Stream<audio.PlaybackEvent> get getPlaybackStateStream =>
      _player.playbackEventStream;

  static final PlayerService _instance = PlayerService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory PlayerService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  PlayerService._internal() {
    _init();
  }

  // Dispose
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _isPlayingSubscribers = {};
    _isConfigured = false;
    _isMiniPlayerReady = false;
    _player = audio.AudioPlayer(
      // Handle audio_session events ourselves for the purpose of this demo.
      handleInterruptions: true,
      androidApplyAudioAttributes: false,
      handleAudioSessionActivation: false,
    );
    _audioHandler = await AudioService.init(
      builder: () => MediaControlsHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'AUDIO_HANDLER_CHANNEL',
        androidNotificationChannelName: 'Media Controls Handler',
        androidNotificationOngoing: false,
        androidShowNotificationBadge: false,
      ),
    );

    // Queues
    _isPlayingSubscribers = await ServiceBus().registerStreamQueueAsync<bool>(
      _IS_PLAYING_QUEUE,
      ['MINI', 'PLAYER', 'POPUP', 'MEDIA', 'INTERRUPT'],
    );
    _player.playingStream.listen((isPlaying) async {
      await ServiceBus().sendMessageAsync<bool>(_IS_PLAYING_QUEUE, isPlaying);
    });

    // Streams
    _lyricsStreamController = StreamController.broadcast();
    _playlistStreamController = StreamController.broadcast();
    _miniPlayerStreamController = StreamController.broadcast();

    _player.processingStateStream.listen((state) async {
      if (state == audio.ProcessingState.completed) await _player.pause();
    });
    _player.sequenceStateStream.listen((sequence) async {
      _prepareMiniPlayer();
      await _prepareActivePlaylistAsync();
      await _prepareActiveSongLyricsAsync(
        tag: sequence.currentSource?.tag as TrackInfo?,
      );
    });
    getPositionDataStream.listen(
      (position) async => await _prepareActiveSongLyricsAsync(),
    );
    _player.androidAudioSessionIdStream.listen(
      (id) async => await _logAudioSessionIdAsync(id),
    );
  }

  Future<void> initPlayerServiceAsync() async {
    if (!_isConfigured) {
      try {
        // Inform the operating system of our app's audio attributes etc.
        // We pick a reasonable default for an app that plays speech.
        _audioSession = await AudioSession.instance;
        await _audioSession!.configure(
          const AudioSessionConfiguration.speech(),
        );
        _audioSession!.setActive(true);
        // Listen to audio interruptions and pause or duck as appropriate.
        _handleInterruptionsAsync(_audioSession!);
        // Listen to errors during playback.
        _player.playbackEventStream.listen(
          (event) {},
          onError: (Object e, StackTrace stackTrace) async {
            await Logger.logAsync(
              LogEvent<PlayerService>(
                severity: Severity.error,
                tag: Tag.service,
                line: 'A stream error occurred: $e',
              ),
            );
          },
        );
        // Player is configured
        _isConfigured = true;
      } on PlatformException catch (e) {
        await Logger.logAsync(
          LogEvent<PlayerService>(
            severity: Severity.error,
            tag: Tag.service,
            line: '${e.message}\n${e.details}',
          ),
        );
      } finally {
        await _loadLastPlayedTrackAsync();
        showNowPlayingNotificationAsync();
        notifyListeners();
      }
    }
  }

  void _handleInterruptionsAsync(AudioSession audioSession) {
    // just_audio can handle interruptions for us, but we have disabled that in
    // order to demonstrate manual configuration.
    bool playInterrupted = false;
    audioSession.becomingNoisyEventStream.listen((_) async {
      await Logger.logAsync(
        LogEvent<PlayerService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'becomingNoisyEventStream: PAUSE',
        ),
      );
      _player.pause();
    });

    getPlayerPlayingStateStream('INTERRUPT')?.listen((isPlaying) {
      playInterrupted = false;
      if (isPlaying) {
        audioSession.setActive(true);
      }
    });

    audioSession.interruptionEventStream.listen((event) async {
      await Logger.logAsync(
        LogEvent<PlayerService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Interruption begin: ${event.begin}',
        ),
      );
      await Logger.logAsync(
        LogEvent<PlayerService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Interruption type: ${event.type}',
        ),
      );

      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            if (audioSession.androidAudioAttributes!.usage ==
                AndroidAudioUsage.game) {
              _player.setVolume(_player.volume / 2);
            }
            playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            if (_player.playing) {
              _player.pause();
              playInterrupted = true;
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(min(1.0, _player.volume * 2));
            playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
            if (playInterrupted) _player.play();
            playInterrupted = false;
            break;
          case AudioInterruptionType.unknown:
            playInterrupted = false;
            break;
        }
      }
    });

    audioSession.devicesChangedEventStream.listen((event) async {
      // Device added
      if (event.devicesAdded.isNotEmpty) {
        await Logger.logAsync(
          LogEvent<PlayerService>(
            severity: Severity.information,
            tag: Tag.service,
            line: 'Devices added:${_formatDevicesOutput(event.devicesAdded)}',
          ),
        );
      }

      // Device removed
      if (event.devicesRemoved.isNotEmpty) {
        await Logger.logAsync(
          LogEvent<PlayerService>(
            severity: Severity.information,
            tag: Tag.service,
            line:
                'Devices removed:${_formatDevicesOutput(event.devicesRemoved)}',
          ),
        );
      }
    });
  }

  Future<int> getAudioSessionIdAsync() async {
    if (_player.androidAudioSessionId == null) {
      await initPlayerServiceAsync();
    }
    return _player.androidAudioSessionId!;
  }

  Future<bool> isPlayerConfiguredAsync() async {
    return _isConfigured;
  }

  void _prepareMiniPlayer() {
    if (!_isMiniPlayerReady) {
      _isMiniPlayerReady = true;
      _miniPlayerStreamController.sink.add(_isMiniPlayerReady);
    }
  }

  Future<void> seekAsync(Duration? duration) async {
    await _player.seek(duration);
  }

  Future<void> playAsync() async {
    // await showNowPlayingNotificationAsync(isPlaying: true);

    // Replay track if processing has completed
    if (_player.playerState.processingState ==
        audio.ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }

    // In most cases does not finish and suspends execution
    await _player.play();
  }

  Future<void> playAlbumAsync(List<Song> songs, int index) async {
    try {
      await _removeFlacTempFilesAsync();
      await _player.setAudioSources(
        await _mapAudioSourceAsync(songs),
        initialIndex: index,
      );
      await _player.play();
    } catch (e) {
      await Logger.logAsync(
        LogEvent<PlayerService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Error loading audio source: $e',
        ),
      );
    }
  }

  Future<void> _removeFlacTempFilesAsync() async {
    for (var source in _player.audioSources.where(
      (source) =>
          !((source as audio.ProgressiveAudioSource).tag as TrackInfo)
              .tmpPath
              .isNull,
    )) {
      try {
        final file = File(((source as audio.ProgressiveAudioSource).tag as TrackInfo).tmpPath!);

        if (await file.exists()) {
          await file.delete(); // Permanently removes the file
          print("File deleted successfully.");
        } else {
          print("File does not exist.");
        }
      } catch (e) {
        print("Error deleting file: $e");
      }
    }
  }

  Future<void> playSingleTrackAsync(Song song) async {
    await _player.setAudioSource(
      audio.AudioSource.file(
        song.path,
        tag: TrackInfo(
          art: song.art,
          path: song.path,
          title: song.name,
          artist: song.artist,
          year: song.yearReleased,
          genre: song.genre,
          dateAdded: song.dateAdded,
          discNumber: song.discNumber,
          mimeType: song.mimeType,
          bitRate: song.bitRate,
          duration: song.duration,
          details: _buildTrackDetails(
            song.name,
            song.artist,
            song.path,
            other: {
              'Disc Number':
                  song.discNumber == 0 ? 'Unknown' : song.discNumber.toString(),
              'Genre': song.genre,
              'Mime Type': song.mimeType,
              'Bitrate':
                  song.bitRate == 0 ? 'Unknown' : song.bitRate.toString(),
              'Year released': song.yearReleased.toString(),
              'Date Added': song.dateAdded,
            },
          ),
        ),
      ),
    );
    await _player.play();
  }

  Future<void> playPlaylistAsync(
    Playlist playlist, {
    bool shouldShuffle = false,
  }) async {
    if (shouldShuffle) _player.setShuffleModeEnabled(shouldShuffle);
    await _setPlaylistAsync(playlist);
    await playAsync();
  }

  Future<void> pauseAsync() async {
    await _player.pause();
    await showNowPlayingNotificationAsync();
  }

  Future<void> previousAsync() async {
    await _player.seekToPrevious();
    await showNowPlayingNotificationAsync();
  }

  Future<void> nextAsync() async {
    await _player.seekToNext();
    await showNowPlayingNotificationAsync();
  }

  Future<void> stopAsync() async {
    await _player.stop();
    await showNowPlayingNotificationAsync();
  }

  Future<void> setPlayerModeAsync(PlayerMode mode) async {
    if (_player.shuffleModeEnabled && !mode.equals(PlayerMode.shuffle)) {
      await _player.setShuffleModeEnabled(false);
    }

    switch (mode) {
      case PlayerMode.playOnce:
        await _player.setLoopMode(audio.LoopMode.off);
        break;
      case PlayerMode.repeatOne:
        await _player.setLoopMode(audio.LoopMode.one);
        break;
      case PlayerMode.repeatAll:
        await _player.setLoopMode(audio.LoopMode.all);
        break;
      case PlayerMode.shuffle:
        await _player.setLoopMode(audio.LoopMode.all);
        break;
    }
  }

  Future<void> _setPlaylistAsync(Playlist playlist) async {
    final List<Song> songs =
        playlist.songs.map((playlist) => playlist.song).toList();
    await _player.setAudioSource(
      audio.ConcatenatingAudioSource(
        children: await _mapAudioSourceAsync(songs),
      ),
    );
    _activePlaylist = playlist;
  }

  Future<void> playSelectedPlaylistSongAsync(
    String path,
    bool isPlaying,
  ) async {
    final audio.IndexedAudioSource nowPlaying = _player.sequenceState.sequence
        .firstWhere((song) => (song.tag as TrackInfo).path.equals(path));
    final int position = _player.sequenceState.sequence.indexOf(nowPlaying);

    if (isPlaying &&
        (_player.sequenceState.currentSource?.equals(nowPlaying) ?? false)) {
      await _player.pause();
    } else if (!isPlaying) {
      await _player.setAudioSource(
        initialIndex: position,
        audio.ConcatenatingAudioSource(
          children:
              _player.sequenceState.sequence
                  .map((e) => e as audio.AudioSource)
                  .toList(),
        ),
      );
      _player.play();
    }
  }

  Future<Playlist> getActivePlaylistAsync() async {
    // if (!_activePlaylist.isNull) return _activePlaylist!;

    List<audio.IndexedAudioSource> sources =
        _player.sequenceState.sequence ?? [];
    List<PlaylistSong> songs = [];

    for (audio.IndexedAudioSource source in sources) {
      final TrackInfo info = source.tag as TrackInfo;
      final bool isPlaying = (_player.sequenceState.currentSource!.tag
              as TrackInfo)
          .path!
          .equals(info.path!);

      songs.add(
        PlaylistSong(
          song: Song(
            id: 0,
            path: info.path!,
            art: info.art!,
            name: info.title!,
            artist: info.artist!,
            duration:
                _player.sequenceState.currentSource!.duration?.inSeconds ??
                const Duration().inSeconds,
            yearReleased: info.year ?? DateTime.now().year,
            genre: info.genre ?? 'Unknown',
            dateAdded: info.dateAdded ?? DateTime.now().toIso8601String(),
            discNumber: info.discNumber ?? 0,
            mimeType: info.mimeType ?? 'Unknown',
            bitRate: info.bitRate ?? 0,
          ),
          isPlaying: isPlaying,
        ),
      );
    }

    _activePlaylist = Playlist(
      id: -1,
      date: DateFormat.yMd().format(DateTime.now()),
      name: 'Now Playing',
      tracks: songs.length,
      songs: songs,
    );

    return _activePlaylist!;
  }

  Future<void> sweepActivePlayingAsync(Playlist playlist) async {
    final audio.IndexedAudioSource? currentSource =
        _player.sequenceState.currentSource;
    final String sourcePath = (currentSource?.tag as TrackInfo).path ?? '';

    if (playlist.songs.isEmpty) {
      playlist = Playlist(
        id: playlist.id,
        date: playlist.date,
        name: playlist.name,
        tracks: playlist.tracks,
        songs:
            _activePlaylist?.songs
                .where((playlistSong) => playlistSong.song.equals(sourcePath))
                .toList() ??
            [PlaylistSong(song: MusicService().getSongByPath(sourcePath))],
      );
    }

    bool isPlaying = _player.playing;
    if (isPlaying) {
      Duration currentPosition = _player.position;
      await _player.pause();
      _player.setAudioSource(
        currentSource as audio.AudioSource,
        initialPosition: currentPosition,
      );
      _playlistStreamController.sink.add(playlist);
      _player.play();
    } else {
      _player.setAudioSource(currentSource as audio.AudioSource);
      _playlistStreamController.sink.add(playlist);
    }
  }

  bool isPlaying() => _player.playing;

  Future<void> showNowPlayingNotificationAsync({bool? isPlaying}) async {
    if (ApplicationLifecycleService.canSendMediaPlayerNotifications()) {
      TrackInfo nowPlaying =
          _player.sequenceState.currentSource!.tag as TrackInfo;

      Uri? image;
      if (nowPlaying.art!.isNotEmpty) {
        final String? path = await ImageStoreService.cacheAlbumArtAsync(
          nowPlaying.title!,
          nowPlaying.art!,
        );
        if (!path.isNull) image = Uri.file(path!);
      }
      await NotificationService().showMediaPlayerNotification(
        nowPlaying.title ?? 'Unknown',
        nowPlaying.artist ?? 'Unknown',
        image.isNull ? 'asset://assets/images/cd.png' : 'file://${image?.path}',
        isPlaying ?? _player.playing,
      );
    }
  }

  Future<void> _loadLastPlayedTrackAsync() async {
    // if (!kReleaseMode) await _loadDebugTrackAsync();
  }

  Future<void> loadRecentlyPlayedTracks(List<Song> songs) async {
    _player.setAudioSources(await _mapAudioSourceAsync(songs));
    if (songs.isNotEmpty) _prepareMiniPlayer();
  }

  // ignore: unused_element
  Future<void> _loadDebugTrackAsync() async {
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      await _player.setAudioSource(
        audio.AudioSource.uri(
          Uri.parse(
            "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
          ),
          tag: TrackInfo(
            art:
                (await NetworkAssetBundle(
                  Uri.parse(
                    'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
                  ),
                ).load(
                  'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
                )).buffer.asUint8List(),
            path:
                'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
            title: "Nature Sounds",
            artist: "Public Domain",
            details: _buildTrackDetails(
              "Nature Sounds",
              "Public Domain",
              'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
              other: {
                'Topic': 'Science Friday',
                'Type': 'Podcast',
                'Format': 'Mp3',
              },
            ),
          ),
        ),
      );
      _prepareMiniPlayer();
    } catch (e) {
      await Logger.logAsync(
        LogEvent<PlayerService>(
          severity: Severity.error,
          tag: Tag.service,
          line: 'Error loading audio source: $e',
        ),
      );
    }
  }

  String _buildTrackDetails(
    String title,
    String artist,
    String path, {
    Map<String, String>? other,
  }) {
    String details = '';
    details += 'Title: $title\n\nArtist: $artist\n\n';

    if (!other.isNull) {
      String mapped = '';
      for (MapEntry<String, String> entry in other!.entries) {
        mapped += '${entry.key.capitalize()}: ${entry.value}\n\n';
      }
      details += mapped;
    }

    details += 'Path: $path';

    return details;
  }

  Future<void> _prepareActivePlaylistAsync() async {
    Playlist playlist = await getActivePlaylistAsync();
    _playlistStreamController.sink.add(playlist);
  }

  Future<void> _logAudioSessionIdAsync(int? id) async {
    // Log Session ID
    await Logger.logAsync(
      LogEvent<PlayerService>(
        severity: Severity.information,
        tag: Tag.service,
        line: 'Audio Session ID: ${id.toString()}',
      ),
    );
  }

  Future<void> _prepareActiveSongLyricsAsync({TrackInfo? tag}) async {
    if (!tag.isNull) {
      _activeSongLyrics = await LyricsService().getTrackLyricsAsync(
        tag?.title ?? '',
        tag?.artist ?? '',
        canSave: UserSettingsService.canSaveLyricsLocally,
      );
    }
    _lyricsStreamController.sink.add(_activeSongLyrics ?? '');
  }

  Future<void> clipTrackAsync(Duration? start, Duration? end) async {
    // await _player.setClip(start: start, end: end);
  }

  Future<List<audio.AudioSource>> _mapAudioSourceAsync(List<Song> songs) async {
    List<audio.AudioSource> sources = [];
    for (Song song in songs) {
      String? convertedPath;
      if (song.path.endsWith('.flac')) {
        convertedPath = await _covertToM4AAsync(song.path);
      }

      sources.add(
        audio.AudioSource.file(
          convertedPath ?? song.path,
          tag: TrackInfo(
            art: song.art,
            path: song.path,
            tmpPath: convertedPath,
            title: song.name,
            artist: song.artist,
            dateAdded: song.dateAdded,
            year: song.yearReleased,
            genre: song.genre,
            discNumber: song.discNumber,
            mimeType: song.mimeType,
            bitRate: song.bitRate,
            duration: song.duration,
            details: _buildTrackDetails(
              song.name,
              song.artist,
              song.path,
              other: {
                'Disc Number':
                    song.discNumber == 0
                        ? 'Unknown'
                        : song.discNumber.toString(),
                'Genre': song.genre,
                'Mime Type': song.mimeType,
                'Bitrate':
                    song.bitRate == 0 ? 'Unknown' : song.bitRate.toString(),
                'Year released': song.yearReleased.toString(),
                'Date Added': song.dateAdded,
              },
            ),
          ),
        ),
      );
    }
    return sources;
  }

  Future<String> _covertToM4AAsync(String oldPath) async {
    try {
      final lastSeparator = oldPath.lastIndexOf(Platform.pathSeparator);
      final directory = oldPath.substring(0, lastSeparator + 1);
      final fileNameWithExt = oldPath.substring(lastSeparator + 1);

      final dotIndex = fileNameWithExt.lastIndexOf('.');
      final baseName =
          dotIndex == -1
              ? fileNameWithExt
              : fileNameWithExt.substring(0, dotIndex);
      final newPath = '$directory$baseName.wav';

      if (File(newPath).existsSync()) return newPath;
      return await AudioDecoder.convertToM4a(oldPath, newPath);
    } on AudioConversionException catch (e) {
      print('Decoding failed: $e');
      return oldPath;
    }
  }

  Future<bool> getIsMiniPlayerReadyAsync() async => _isMiniPlayerReady;

  String _formatDevicesOutput(Set<AudioDevice> devices) {
    String output = '\n';

    for (AudioDevice device in devices) {
      output += '\n\tDevice Name: ${device.name}';
      output += '\n\tDevice Type: ${describeEnum(device.type).capitalize()}';
      output +=
          '\n\tDevice Direction: '
          'Input - ${device.isInput ? 'Yes' : 'No'} '
          '| Output - ${device.isOutput ? 'Yes' : 'No'}';
      output += '\n\n';
    }

    return output;
  }
}
