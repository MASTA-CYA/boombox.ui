import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/playlist-component/models/album_search_result_model.dart';
import 'package:boombox/playlist-component/models/artist_search_result_model.dart';
import 'package:boombox/playlist-component/models/search_result_model.dart';
import 'package:flutter/material.dart';

class ArtistSearchResultWidget extends StatefulWidget {
  final List<SearchResult<ArtistSearchResult>> artists;
  final void Function(List<Song> songs) onSongSelected;

  const ArtistSearchResultWidget({
    super.key,
    required this.artists,
    required this.onSongSelected,
  });

  @override
  State<ArtistSearchResultWidget> createState() =>
      _ArtistSearchResultWidgetState();
}

class _ArtistSearchResultWidgetState extends State<ArtistSearchResultWidget> {
  late List<SearchResult<ArtistSearchResult>> _artists;
  late List<bool> _artistExpansionState;
  late List<bool> _albumExpansionState;
  late List<int> _tracks;

  @override
  void initState() {
    super.initState();

    _artists = widget.artists;
    _artistExpansionState = [];
    _albumExpansionState = [];
    _tracks = [];

    for (int i = 0; i < _artists.length; i++) {
      final List<SearchResult<AlbumSearchResult>> albums =
          _artists.elementAt(i).media.albums;
      _artistExpansionState.add(false);
      for (int j = 0; j < albums.length; j++) {
        _albumExpansionState.add(false);
      }
      _tracks.add(
        albums.length > 1
            ? albums
                .map((e) => e.media.album.tracks)
                .reduce((first, second) => first + second)
            : albums.elementAt(0).media.album.tracks,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: _artists.length,
      itemBuilder: (context, index) => Column(
        children: [
          CheckboxListTile(
            tileColor: Theme.of(context).brightness.equals(Brightness.dark)
                ? ColorHelper.darken(
                    Theme.of(context).colorScheme.secondary, 50)
                : ColorHelper.lighten(
                    Theme.of(context).colorScheme.secondary, 40),
            controlAffinity: ListTileControlAffinity.trailing,
            secondary: IconButton(
              onPressed: () => _updateArtistExpansionState(index),
              icon: Icon(
                _artistExpansionState.elementAt(index)
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),
            title: Text(_artists.elementAt(index).media.artist),
            subtitle: Container(
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
                        widget.artists
                            .elementAt(index)
                            .media
                            .albums
                            .length
                            .toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.merge(
                              TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
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
                        _tracks.elementAt(index).toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.merge(
                              TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            value: _artists.elementAt(index).isSelected,
            onChanged: (isSelected) async =>
                _onArtistSelected(index, isSelected ?? false),
          ),
          const SizedBox(
            height: 5,
          ),
          _artistExpansionState.elementAt(index)
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildAlbums(
                      index, _artists.elementAt(index).media.albums),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildAlbums(
      int artistIndex, List<SearchResult<AlbumSearchResult>> albums) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: albums.length,
      itemBuilder: (context, index) => Column(
        children: [
          CheckboxListTile(
            tileColor: Theme.of(context).brightness.equals(Brightness.dark)
                ? ColorHelper.darken(
                    Theme.of(context).colorScheme.secondary,
                    70,
                  )
                : ColorHelper.lighten(
                    Theme.of(context).colorScheme.secondary,
                    70,
                  ),
            controlAffinity: ListTileControlAffinity.trailing,
            secondary: IconButton(
              onPressed: () => _updateAlbumExpansionState(artistIndex, index),
              icon: Icon(
                _albumExpansionState.elementAt(index)
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),
            title: Text(albums.elementAt(index).media.album.name),
            subtitle: Text(
              albums.elementAt(index).media.album.artist,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
            ),
            value: albums.elementAt(index).isSelected,
            onChanged: (isSelected) async =>
                _onAlbumSelected(artistIndex, index, isSelected ?? false),
          ),
          const SizedBox(
            height: 5,
          ),
          _albumExpansionState.elementAt(index)
              ? _buildSongs(
                  artistIndex,
                  index,
                  albums.elementAt(index).media.songs,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSongs(
      int artistIndex, int albumIndex, List<SearchResult<Song>> songs) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: songs.length,
      itemBuilder: (context, index) => Column(
        children: [
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.trailing,
            secondary: ClipRRect(
              child: Image.memory(songs.elementAt(index).media.art),
            ),
            title: Text(songs.elementAt(index).media.name),
            subtitle: Text(
              songs.elementAt(index).media.artist,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
            ),
            value: songs.elementAt(index).isSelected,
            onChanged: (isSelected) async => await _onSongSelected(
                artistIndex, albumIndex, index, isSelected ?? false),
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

  void _onArtistSelected(int index, bool isSelected) {
    for (int i = 0; i < _artists.elementAt(index).media.albums.length; i++) {
      _onAlbumSelected(index, i, isSelected);
    }
    SearchResult<ArtistSearchResult> artist = _artists.elementAt(index);
    artist.isSelected = isSelected;
    _artists.removeAt(index);
    _artists.insert(index, artist);

    setState(() {});
  }

  void _onAlbumSelected(int artistIndex, int albumIndex, bool isSelected) {
    SearchResult<AlbumSearchResult> album =
        _artists.elementAt(artistIndex).media.albums.elementAt(albumIndex);

    // Mark all songs as selected
    List<SearchResult<Song>> updated = [];
    for (SearchResult<Song> song in album.media.songs) {
      song.isSelected = isSelected;
      updated.add(song);
    }
    album.media.songs = updated;

    // Mark album as selected
    album.isSelected = isSelected;
    _artists.elementAt(artistIndex).media.albums.removeAt(albumIndex);
    _artists.elementAt(artistIndex).media.albums.insert(albumIndex, album);

    widget.onSongSelected(
      _artists
          .elementAt(artistIndex)
          .media
          .albums
          .elementAt(albumIndex)
          .media
          .songs
          .where((song) => song.isSelected!)
          .map((result) => result.media)
          .toList(),
    );

    setState(() {});
  }

  Future _onSongSelected(
      int artistIndex, int albumIndex, int index, bool isSelected) async {
    SearchResult<Song> song = _artists
        .elementAt(artistIndex)
        .media
        .albums
        .elementAt(albumIndex)
        .media
        .songs
        .elementAt(index);
    song.isSelected = isSelected;
    _artists
        .elementAt(artistIndex)
        .media
        .albums
        .elementAt(albumIndex)
        .media
        .songs
        .removeAt(index);
    _artists
        .elementAt(artistIndex)
        .media
        .albums
        .elementAt(albumIndex)
        .media
        .songs
        .insert(index, song);

    widget.onSongSelected(
      _artists
          .elementAt(artistIndex)
          .media
          .albums
          .elementAt(albumIndex)
          .media
          .songs
          .where((song) => song.isSelected!)
          .map((result) => result.media)
          .toList(),
    );

    setState(() {});
  }

  void _updateArtistExpansionState(int index) {
    final bool isExpanded = _artistExpansionState.elementAt(index);
    _artistExpansionState.removeAt(index);
    _artistExpansionState.insert(index, !isExpanded);

    setState(() {});
  }

  void _updateAlbumExpansionState(int artistIndex, int index) {
    final bool isExpanded = _albumExpansionState.elementAt(index);
    _albumExpansionState.removeAt(index);
    _albumExpansionState.insert(index, !isExpanded);

    setState(() {});
  }
}
