// ignore: unused_import
import 'dart:math';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/helpers/enums/snackbar_duration_enum.dart';
import 'package:boombox/common/helpers/enums/snackbar_type_enum.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/common/widgets/notifications/notification_scaffold.dart';
import 'package:boombox/common/widgets/page_background.dart';
import 'package:boombox/library-component/services/library_service.dart';
import 'package:boombox/library-component/widgets/application_feature_carousel.dart';
import 'package:boombox/music-component/music_page.dart';
import 'package:boombox/player-component/barrels/player_barrel.dart';
import 'package:boombox/player-component/player_page.dart';
import 'package:boombox/player-component/widgets/mini-player/mini_player.dart';
import 'package:boombox/player-component/widgets/mini-player/popup_mini_player.dart';
import 'package:boombox/playlist-component/playlist_page.dart';
import 'package:boombox/recently-played-component/recently_played_page.dart';
import 'package:boombox/services_barrel.dart';
import 'package:boombox/settings-component/settings_page.dart';
import 'package:boombox/player-component/barrels/commons_barrel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryPage();
}

class _LibraryPage extends State<LibraryPage> {
  final String _title = 'Library';

  final ValueNotifier<bool> _isPlayerHidden = ValueNotifier<bool>(false);

  late int _popAttempts;

  @override
  void initState() {
    super.initState();

    _popAttempts = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => PopScope(
          onPopInvoked: (didPop) async => await _onPopInvoked(),
          child: Scaffold(
            appBar: AppBarWidget<LibraryPage>(title: _title),
            body: PageBackgroundWidget(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Functions.horizontalScreenMargin(context),
                  vertical: 10,
                ),
                child: NotificationScaffoldWidget(
                  child: _buildLibraryList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryList() {
    return Column(
      children: [
        Expanded(child: _buildLibraryCategories()),
        const SizedBox(height: 10),
        Expanded(child: _buildUserPreferredFeature()),
      ],
    );
  }

  Widget _buildLibraryCategories() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        ListTile(
          leading: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/cd.png'),
              width: 70,
              height: 70,
              allowUpscaling: false,
            ),
          ),
          title: const Text('All Music'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () => _navigateTo<MusicPage>(const MusicPage()),
        ),
        const Divider(
          thickness: 1,
          indent: 10, endIndent: 10,
        ),
        ListTile(
          leading: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/playlist.png'),
              width: 70,
              height: 70,
              allowUpscaling: false,
            ),
          ),
          title: const Text('Playlists'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () => _navigateTo<PlaylistPage>(const PlaylistPage()),
        ),
        const Divider(
          thickness: 1,
          indent: 10, endIndent: 10,
        ),
        ListTile(
          leading: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/recent.png'),
              width: 70,
              height: 70,
              allowUpscaling: false,
            ),
          ),
          title: const Text('Recently Played'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () =>
              _navigateTo<RecentlyPlayedPage>(const RecentlyPlayedPage()),
        ),
        const Divider(
          thickness: 1,
          indent: 10, endIndent: 10,
        ),
        ListTile(
          leading: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/settings.png'),
              width: 70,
              height: 70,
              allowUpscaling: false,
            ),
          ),
          title: const Text('Settings'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () => _navigateTo<SettingsPage>(const SettingsPage()),
        ),
      ],
    );
  }

  Widget _buildUserPreferredFeature() {
    return FutureBuilder(
      future: Future.wait([Provider.of<UserSettingsService>(
        context,
        listen: false,
      ).getCanShowApplicationFeaturesAsync(), Provider.of<PlayerService>(
        context,
        listen: false,
      ).isPlayerConfiguredAsync()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final bool canShowFeatures = snapshot.data![0];
          final bool isPlayerConfigured = snapshot.data![1];
          return canShowFeatures && isPlayerConfigured
              ? _buildApplicationFeature(snapshot.data![0])
              : _buildMiniPlayer(snapshot.data![0]);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildMiniPlayer(bool canPersistFeatures) {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getMiniPlayerStateStream,
      builder: (context, snapshot) {
        if (snapshot.data ?? true) {
          return FutureBuilder(
            future: Provider.of<PlayerService>(
              context,
              listen: false,
            ).getIsMiniPlayerReadyAsync(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                if (!snapshot.data!) {
                  return _buildApplicationFeature(canPersistFeatures);
                } else {
                  return MiniPlayerWidget(key: UniqueKey());
                }
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        } else {
          return MiniPlayerWidget(key: UniqueKey());
        }
      },
    );
  }

  Widget _buildApplicationFeature(bool canPersistFeatures) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) => details.delta.dy < 0
          ? _onShouldHidePlayerPressed(false)
          : _onShouldHidePlayerPressed(true),
      child: canPersistFeatures
          ? Column(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildFeatureCarousel(),
                ),
                Expanded(
                  child: _buildPopupPlayer(),
                ),
              ],
            )
          : _buildFeatureCarousel(),
    );
  }

  Widget _buildFeatureCarousel() {
    return Consumer<LibraryService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.getApplicationFeaturesAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ApplicationFeatureCarouselWidget(
              features: snapshot.data!,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildPopupPlayer() {
    return ValueListenableBuilder(
      valueListenable: _isPlayerHidden,
      builder: (context, isHidden, child) => StreamBuilder(
        stream: Provider.of<MusicService>(context).getIsMappingStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.data!.isBusy) {
            return StreamBuilder(
              stream:
                  Provider.of<PlayerService>(context).getSequenceStateStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && !isHidden) {
                  TrackInfo? info =
                      snapshot.data!.currentSource?.tag as TrackInfo?;
                  if (!info.isNull) {
                    return PopupMiniPlayerWidget(
                      song: info!,
                      onPlayPausePressed: (isPlaying) =>
                          _onPlayPausePressed(isPlaying),
                      onShouldHidePressed: (shouldHide) =>
                          _onShouldHidePlayerPressed(shouldHide),
                      onNavigatorToPlayerPressed: () => _navigateTo<PlayerPage>(
                        const PlayerPage(),
                        direction: TransitionDirection.btt,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  _onShouldHidePlayerPressed(bool shouldHide) {
    _isPlayerHidden.value = shouldHide;
  }

  void _onPlayPausePressed(bool isPlaying) async {
    isPlaying
        ? await Provider.of<PlayerService>(
            context,
            listen: false,
          ).pauseAsync()
        : await Provider.of<PlayerService>(
            context,
            listen: false,
          ).playAsync();
  }

  void _navigateTo<T>(
    Widget widget, {
    TransitionDirection direction = TransitionDirection.ltr,
  }) async {
    if (T.equals(MusicPage) || T.equals(RecentlyPlayedPage)) {
      final bool isBusy = await Provider.of<MusicService>(
        context,
        listen: false,
      ).isBusyMapping();
      if (mounted && isBusy) {
        SnackbarHelper.showMessage(
          context,
          SnackbarType.information,
          'Still loading media categories',
        );
        return;
      }
    }

    if (mounted) {
      PageNavigator.navigateTo<T>(
        context,
        widget,
        direction: direction,
      );
    }
  }

  Future<bool> _onPopInvoked() async {
    final bool canExit = _popAttempts++ == 2;
    if (!canExit) {
      SnackbarHelper.showMessage(
        context,
        SnackbarType.warning,
        duration: SnackbarDuration.short,
        'Press the back button again to exit',
      );
    } else {
      SnackbarHelper.showMessage(
        context,
        SnackbarType.information,
        duration: SnackbarDuration.infinite,
        'Application is shutting down',
      );
    }
    _popAttempts++;
    return canExit;
  }
}
