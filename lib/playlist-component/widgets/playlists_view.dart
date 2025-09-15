import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/services/playlist_service.dart';
import 'package:boombox/playlist-component/widgets/add/add_playlist_view.dart';
import 'package:boombox/playlist-component/widgets/no_playlist_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistsWidget extends StatelessWidget {
  final bool? isParentModal;
  final void Function(Playlist playlist) onPlaylistSelected;

  const PlaylistsWidget({
    super.key,
    required this.onPlaylistSelected,
    this.isParentModal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isParentModal!) {
      return Scaffold(
        body: _buildPlaylist(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onCreateNewPlaylistPressed(context),
          child: Icon(
            Icons.add,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      );
    } else {
      return _buildPlaylist();
    }
  }

  Widget _buildPlaylist() {
    return Consumer<PlaylistService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.getPlaylistsAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Playlist> playlists = snapshot.data!;

            if (snapshot.data!.isEmpty) {
              return Center(
                  child: NoPlaylistViewWidget(minify: isParentModal!));
            } else {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: playlists.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    ListTile(
                      leading: const ImageIcon(
                        ResizeImage(
                          AssetImage('assets/images/playlist.png'),
                          width: 1000,
                          height: 1000,
                          allowUpscaling: false,
                        ),
                      ),
                      title: Text(playlists.elementAt(index).name),
                      subtitle: Text(
                        playlists.elementAt(index).date,
                        style: Theme.of(context).textTheme.bodyMedium?.merge(
                              TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                      ),
                      trailing: Text(
                        playlists.elementAt(index).tracks.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      onTap: () =>
                          onPlaylistSelected(playlists.elementAt(index)),
                    ),
                    const Divider(
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                ),
              );
            }
          } else {
            return const CircularProgressIndicatorWidget();
          }
        },
      ),
    );
  }

  void _onCreateNewPlaylistPressed(BuildContext context) {
    PageNavigator.navigateTo(context, const AddPlaylistWidget());
  }
}
