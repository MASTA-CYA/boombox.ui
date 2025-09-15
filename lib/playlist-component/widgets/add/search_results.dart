import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/music-component/services/music_service.dart';
import 'package:boombox/music-component/widgets/no_music.dart';
import 'package:boombox/playlist-component/models/album_search_result_model.dart';
import 'package:boombox/playlist-component/models/artist_search_result_model.dart';
import 'package:boombox/playlist-component/models/search_result_model.dart';
import 'package:boombox/playlist-component/widgets/add/album_search_result.dart';
import 'package:boombox/playlist-component/widgets/add/artist_search_result.dart';
import 'package:boombox/playlist-component/widgets/add/no_search_results.dart';
import 'package:boombox/playlist-component/widgets/add/song_search_result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchResultsWidget<T> extends StatefulWidget {
  final String? searchText;
  final List<Song> selectedMedia;
  final void Function(List<Song> songs) onSongSelected;

  const SearchResultsWidget({
    super.key,
    this.searchText,
    required this.selectedMedia,
    required this.onSongSelected,
  });

  @override
  State<StatefulWidget> createState() => _SearchResultsWidget<T>();
}

class _SearchResultsWidget<T> extends State<SearchResultsWidget<T>> {
  final ValueNotifier<List<SearchResult<Song>>?> _songs =
      ValueNotifier<List<SearchResult<Song>>?>(null);
  final ValueNotifier<List<SearchResult<AlbumSearchResult>>?> _albums =
      ValueNotifier<List<SearchResult<AlbumSearchResult>>?>(null);
  final ValueNotifier<List<SearchResult<ArtistSearchResult>>?> _artists =
      ValueNotifier<List<SearchResult<ArtistSearchResult>>?>(null);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildWidget = const SizedBox.shrink();

    if (widget.searchText.isNull || (widget.searchText?.isEmpty ?? true)) {
      return const NoResultsForSearchWidget();
    }

    switch (T) {
      case Song:
        buildWidget = FutureBuilder(
          future: Provider.of<MusicService>(
            context,
            listen: false,
          ).searchMusicLibraryAsync<Song>(searchText: widget.searchText),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final List<SearchResult<Song>> searchedSongs = snapshot.data!
                    .map(
                      (song) => _mapSongSearchResults(song),
                    )
                    .toList();
                _songs.value = searchedSongs;
                return SongSearchResultWidget(
                  songs: searchedSongs,
                  onSongSelected: (songs) => _onSongSelected(songs),
                );
              } else {
                return const NoResultsForSearchWidget();
              }
            } else {
              return const Center(
                child: CircularProgressIndicatorWidget(),
              );
            }
          },
        );

        break;
      case Album:
        buildWidget = FutureBuilder(
          future: Provider.of<MusicService>(
            context,
            listen: false,
          ).searchMusicLibraryAsync<Album>(searchText: widget.searchText),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final List<SearchResult<AlbumSearchResult>> searchedAlbum =
                    snapshot.data!
                        .map(
                          (album) => _mapAlbumSearchResults(album),
                        )
                        .toList();
                _albums.value = searchedAlbum;
                return AlbumSearchResultWidget(
                  albums: searchedAlbum,
                  onSongSelected: (songs) => _onSongSelected(songs),
                );
              } else {
                return const NoResultsForSearchWidget();
              }
            } else {
              return const Center(
                child: CircularProgressIndicatorWidget(),
              );
            }
          },
        );

        break;
      case Artist:
        buildWidget = FutureBuilder(
          future: Provider.of<MusicService>(
            context,
            listen: false,
          ).searchMusicLibraryAsync<Artist>(searchText: widget.searchText),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return FutureBuilder(
                  future: _mapArtistSearchResults(snapshot.data!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        _artists.value = snapshot.data!;
                        return ArtistSearchResultWidget(
                          artists: snapshot.data!,
                          onSongSelected: (songs) => _onSongSelected(songs),
                        );
                      } else {
                        return const NoResultsForSearchWidget();
                      }
                    } else {
                      return const Center(
                        child: NoResultsForSearchWidget(),
                      );
                    }
                  },
                );
              } else {
                return const Center(
                  child: NoResultsForSearchWidget(),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicatorWidget(),
              );
            }
          },
        );

        break;
      default:
        buildWidget = const NoMusicWidget();
        break;
    }

    return buildWidget;
  }

  Future _onSongSelected(List<Song> songs) async {
    widget.onSongSelected(songs);
  }

  SearchResult<Song> _mapSongSearchResults(Song song) {
    if (widget.selectedMedia.contains(song)) {
      return SearchResult<Song>(media: song, isSelected: true);
    } else {
      return SearchResult<Song>(media: song);
    }
  }

  SearchResult<AlbumSearchResult> _mapAlbumSearchResults(Album album) {
    List<SearchResult<Song>> songs = [];

    for (Song song in album.songs) {
      songs.add(_mapSongSearchResults(song));
    }

    return SearchResult<AlbumSearchResult>(
      media: AlbumSearchResult(
        album: album,
        songs: songs,
      ),
    );
  }

  Future<List<SearchResult<ArtistSearchResult>>> _mapArtistSearchResults(
    List<Artist> artist,
  ) async {
    List<SearchResult<ArtistSearchResult>> artistResult = [];
    List<SearchResult<AlbumSearchResult>> albumResult = [];
    List<Album> albums = [];

    for (Artist artist in artist) {
      albums = await Provider.of<MusicService>(
        context,
        listen: false,
      ).getAlbumsByArtistAsync(artist.name);

      for (Album album in albums) {
        albumResult.add(
          SearchResult<AlbumSearchResult>(
            media: AlbumSearchResult(
              album: album,
              songs: album.songs
                  .map((song) => SearchResult<Song>(media: song))
                  .toList(),
            ),
          ),
        );
      }

      artistResult.add(
        SearchResult<ArtistSearchResult>(
          media: ArtistSearchResult(
            artist: artist.name,
            albums: List.from(albumResult),
          ),
        ),
      );

      albumResult.clear();
    }

    return artistResult;
  }
}
