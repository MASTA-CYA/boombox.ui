import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/services/media_art_service.dart';
import 'package:boombox/music-component/widgets/artist_album_view.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:flutter/material.dart';

class ArtistViewWidget extends StatefulWidget {
  final List<Artist> artists;
  final void Function(int id) onArtistSelected;

  const ArtistViewWidget({
    super.key,
    required this.artists,
    required this.onArtistSelected,
  });

  @override
  State<StatefulWidget> createState() => _ArtistViewWidget();
}

class _ArtistViewWidget extends State<ArtistViewWidget> {
  late List<String> images;

  @override
  void initState() {
    super.initState();

    images = [];
  }

  @override
  Widget build(BuildContext context) {
    images.clear();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: widget.artists.length,
      itemBuilder:
          (context, index) => Column(
            children: [
              ListTile(
                visualDensity: VisualDensity.comfortable,
                leading: _buildArtistMedia(
                  widget.artists.elementAt(index).name,
                ),
                title: Text(widget.artists.elementAt(index).name),
                subtitle: _buildSubtitle(index),
                onTap:
                    () async => _onArtistSelected(
                      widget.artists.elementAt(index).id,
                      images.elementAt(index),
                      widget.artists.elementAt(index),
                    ),
              ),
              const Divider(thickness: 1, indent: 10, endIndent: 10),
            ],
          ),
    );
  }

  Widget _buildArtistMedia(String artist) {
    return FutureBuilder(
      future: MediaArtService().getArtistArtAsync(
        artist,
        UserSettingsService.canDownloadArtistMedia,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data!.isNotEmpty) {
          images.add(snapshot.data!);
          return Image(
            image: ResizeImage(
              NetworkImage(snapshot.data!),
              width: 120,
              height: 120,
              allowUpscaling: false,
            ),
            loadingBuilder:
                (context, child, loadingProgress) =>
                    loadingProgress?.cumulativeBytesLoaded ==
                            loadingProgress?.expectedTotalBytes
                        ? child
                        : const ImageIcon(
                          ResizeImage(
                            AssetImage('assets/images/artist.png'),
                            width: 120,
                            height: 120,
                            allowUpscaling: false,
                          ),
                        ),
            errorBuilder:
                (context, error, stackTrace) => const ImageIcon(
                  ResizeImage(
                    AssetImage('assets/images/artist.png'),
                    width: 120,
                    height: 120,
                    allowUpscaling: false,
                  ),
                ),
          );
        } else {
          return const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/artist.png'),
              width: 70,
              height: 70,
              allowUpscaling: false,
            ),
          );
        }
      },
    );
  }

  Widget _buildSubtitle(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const ImageIcon(
                ResizeImage(
                  AssetImage('assets/images/album.png'),
                  width: 70,
                  height: 70,
                  allowUpscaling: false,
                ),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.artists.elementAt(index).albums.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const ImageIcon(
                ResizeImage(
                  AssetImage('assets/images/cd.png'),
                  width: 70,
                  height: 70,
                  allowUpscaling: false,
                ),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.artists.elementAt(index).tracks.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onArtistSelected(int id, String image, Artist artist) async {
    widget.onArtistSelected(id);
    PageNavigator.navigateTo(
      context,
      ArtistAlbumWidget(image: image, artist: artist),
    );
  }
}
