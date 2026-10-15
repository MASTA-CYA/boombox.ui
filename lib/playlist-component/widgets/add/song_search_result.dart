import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/playlist-component/models/search_result_model.dart';
import 'package:flutter/material.dart';

class SongSearchResultWidget extends StatefulWidget {
  final List<SearchResult<Song>> songs;
  final void Function(List<Song> songs) onSongSelected;

  const SongSearchResultWidget({
    super.key,
    required this.songs,
    required this.onSongSelected,
  });

  @override
  State<SongSearchResultWidget> createState() => _SongSearchResultWidgetState();
}

class _SongSearchResultWidgetState extends State<SongSearchResultWidget> {
  late List<SearchResult<Song>> _songs;

  @override
  void initState() {
    super.initState();

    _songs = widget.songs;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      cacheExtent: 5,
      itemCount: _songs.length,
      itemBuilder: (context, index) => Column(
        children: [
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.trailing,
            secondary: ClipRRect(
              child: _songs.elementAt(index).media.art.isEmpty
                  ? Image.asset('assets/images/cd.png')
                  : Image.memory(_songs.elementAt(index).media.art),
            ),
            title: Text(_songs.elementAt(index).media.name),
            subtitle: Text(
              _songs.elementAt(index).media.artist,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
            ),
            value: _songs.elementAt(index).isSelected,
            onChanged: (isSelected) async =>
                await _onSongSelected(index, isSelected ?? false),
          ),
          const Divider(
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
        ],
      ),
    );
  }

  Future _onSongSelected(int index, bool isSelected) async {
    SearchResult<Song> song = _songs.elementAt(index);
    song.isSelected = isSelected;
    _songs.removeAt(index);
    _songs.insert(index, song);

    widget.onSongSelected(
      _songs
          .where((song) => song.isSelected!)
          .map((result) => result.media)
          .toList(),
    );

    setState(() {});
  }
}
