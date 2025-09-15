import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/playlist-component/models/album_search_result_model.dart';
import 'package:boombox/playlist-component/models/search_result_model.dart';
import 'package:flutter/material.dart';

class AlbumSearchResultWidget extends StatefulWidget {
  final List<SearchResult<AlbumSearchResult>> albums;
  final void Function(List<Song> songs) onSongSelected;

  const AlbumSearchResultWidget({
    super.key,
    required this.albums,
    required this.onSongSelected,
  });

  @override
  State<AlbumSearchResultWidget> createState() =>
      _AlbumSearchResultWidgetState();
}

class _AlbumSearchResultWidgetState extends State<AlbumSearchResultWidget> {
  late List<SearchResult<AlbumSearchResult>> _albums;
  late List<bool> _albumExpansionState;

  @override
  void initState() {
    super.initState();

    _albums = widget.albums;
    _albumExpansionState = [];

    for (var i = 0; i < _albums.length; i++) {
      _albumExpansionState.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: _albums.length,
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
              onPressed: () => _updateAlbumExpansionState(index),
              icon: Icon(
                _albumExpansionState.elementAt(index)
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),
            title: Text(_albums.elementAt(index).media.album.name),
            subtitle: Text(
              _albums.elementAt(index).media.album.artist,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
            ),
            value: _albums.elementAt(index).isSelected,
            onChanged: (isSelected) async =>
                await _onAlbumSelected(index, isSelected ?? false),
          ),
          const SizedBox(
            height: 5,
          ),
          _albumExpansionState.elementAt(index)
              ? _buildSongs(index, _albums.elementAt(index).media.songs)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSongs(int albumIndex, List<SearchResult<Song>> songs) {
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
            onChanged: (isSelected) async =>
                await _onSongSelected(albumIndex, index, isSelected ?? false),
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

  Future _onAlbumSelected(int index, bool isSelected) async {
    SearchResult<AlbumSearchResult> album = _albums.elementAt(index);

    // Mark all songs as selected
    List<SearchResult<Song>> updated = [];
    for (SearchResult<Song> song in album.media.songs) {
      song.isSelected = isSelected;
      updated.add(song);
    }
    album.media.songs = updated;

    // Mark album as selected
    album.isSelected = isSelected;
    _albums.removeAt(index);
    _albums.insert(index, album);

    widget.onSongSelected(
      _albums
          .elementAt(index)
          .media
          .songs
          .where((song) => song.isSelected!)
          .map((result) => result.media)
          .toList(),
    );

    setState(() {});
  }

  Future _onSongSelected(int albumIndex, int index, bool isSelected) async {
    SearchResult<Song> song =
        _albums.elementAt(albumIndex).media.songs.elementAt(index);
    song.isSelected = isSelected;
    _albums.elementAt(albumIndex).media.songs.removeAt(index);
    _albums.elementAt(albumIndex).media.songs.insert(index, song);

    widget.onSongSelected(
      _albums
          .elementAt(albumIndex)
          .media
          .songs
          .where((song) => song.isSelected!)
          .map((result) => result.media)
          .toList(),
    );

    setState(() {});
  }

  void _updateAlbumExpansionState(int index) {
    final bool isExpanded = _albumExpansionState.elementAt(index);
    _albumExpansionState.removeAt(index);
    _albumExpansionState.insert(index, !isExpanded);

    setState(() {});
  }
}
