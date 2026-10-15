import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/helpers/enums/snackbar_type_enum.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/notifications/notification_scaffold.dart';
import 'package:boombox/music-component/services/music_service.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/widgets/add/add_playlist_view.dart';
import 'package:boombox/playlist-component/widgets/playlist_view.dart';
import 'package:boombox/playlist-component/widgets/playlists_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlaylistPage();
}

class _PlaylistPage extends State<PlaylistPage> {
  final String _title = 'Playlists';

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<PlaylistPage>(title: _title),
          drawer: null,
          body: NotificationScaffoldWidget(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Functions.horizontalScreenMargin(context),
                vertical: 10,
              ),
              child: _buildPlaylists(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _onAddPlaylistPressed(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylists() {
    return PlaylistsWidget(
      onPlaylistSelected: (playlist) => _onPlaylistSelected(playlist),
    );
  }

  void _onAddPlaylistPressed() {
    _navigateTo<AddPlaylistWidget>(const AddPlaylistWidget());
  }

  void _onPlaylistSelected(Playlist playlist) {
    _navigateTo<PlaylistWidget>(PlaylistWidget(playlist: playlist));
  }

  void _navigateTo<T>(Widget widget) async {
    if (T == AddPlaylistWidget) {
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
      );
    }
  }
}
