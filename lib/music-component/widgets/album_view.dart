import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/widgets/trailing_card.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/widgets/album_songs_view.dart';
import 'package:flutter/material.dart';

class AlbumViewWidget extends StatefulWidget {
  final List<Album> albums;
  final void Function(int id) onAlbumSelected;

  const AlbumViewWidget({
    super.key,
    required this.albums,
    required this.onAlbumSelected,
  });

  @override
  State<StatefulWidget> createState() => _AlbumViewWidget();
}

class _AlbumViewWidget extends State<AlbumViewWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: widget.albums.length,
      itemBuilder:
          (context, index) => Column(
            children: [
              ListTile(
                leading: ClipRRect(
                  child:
                      widget.albums.elementAt(index).art.isEmpty
                          ? Image.asset(
                            'assets/images/album.png',
                            color: Theme.of(context).iconTheme.color,
                          )
                          : Image.memory(widget.albums.elementAt(index).art),
                ),
                title: Text(widget.albums.elementAt(index).name),
                subtitle: Text(
                  widget.albums.elementAt(index).artist,
                  style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                trailing: TrailingCardWidget(
                  child: Text(
                    widget.albums.elementAt(index).tracks.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                onTap: () => _onAlbumSelected(index),
              ),
              if (index < widget.albums.length - 1)
                const Divider(thickness: 1, indent: 10, endIndent: 10),
            ],
          ),
    );
  }

  void _onAlbumSelected(int index) async {
    widget.onAlbumSelected(widget.albums.elementAt(index).id);
    PageNavigator.navigateTo<AlbumViewWidget>(
      context,
      AlbumSongsWidget(album: widget.albums.elementAt(index)),
    );
  }
}
