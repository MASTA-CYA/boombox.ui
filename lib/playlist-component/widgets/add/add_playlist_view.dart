import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/debouncer.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/helpers/enums/snackbar_type_enum.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/search_bar.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:boombox/playlist-component/widgets/add/selected_songs.dart';
import 'package:boombox/playlist-component/widgets/edit/edit_playlist_view.dart';
import 'package:boombox/playlist-component/widgets/playlist_button.dart';
import 'package:boombox/playlist-component/widgets/add/search_results.dart';
import 'package:boombox/playlist-component/widgets/add/search_type_toggle.dart';
import 'package:flutter/material.dart';

class AddPlaylistWidget extends StatefulWidget {
  const AddPlaylistWidget({super.key});

  @override
  State<StatefulWidget> createState() => _AddPlaylistWidget();
}

class _AddPlaylistWidget extends State<AddPlaylistWidget> {
  final String _title = 'New';

  late ScrollController _scrollController;
  final ValueNotifier<bool> _canScrollToTop = ValueNotifier<bool>(false);

  late Debouncer _debouncer;
  final ValueNotifier<String?> _searchText = ValueNotifier<String?>(null);

  final ValueNotifier<List<Song>> _selectedSongs =
      ValueNotifier<List<Song>>([]);
  late Type _searchType;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() => _onSearchResultsViewScroll());

    _debouncer = Debouncer(milliseconds: 800);
    _searchType = Song;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {},
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<AddPlaylistWidget>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildAddPlaylistScaffold(),
          ),
          floatingActionButton: ValueListenableBuilder(
            valueListenable: _canScrollToTop,
            builder: (context, canScroll, child) {
              return canScroll
                  ? Container(
                      margin: const EdgeInsets.only(top: 70),
                      child: FloatingActionButton(
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                        onPressed: () => _scrollToTopPressed(),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }

  Widget _buildAddPlaylistScaffold() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildSearchBarAndSearchTypeToggle(),
                  _buildSearchResults(),
                ],
              ),
            ),
          ),
          _buildButtonBar(),
          _buildSelectedSongs(),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndSearchTypeToggle() {
    return Row(
      children: [
        Expanded(child: _buildSearchBar()),
        _buildSearchTypeToggle(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidget(
      onTextChanged: (text) async => _searchForMedia(text),
    );
  }

  Widget _buildSearchTypeToggle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: SearchTypeToggleWidget(
        key: UniqueKey(),
        searchType: _searchType,
        onSearchTypeChanged: (type) => _onSearchTypeChanged(type),
      ),
    );
  }

  Widget _buildSearchResults() {
    Widget widget = const SizedBox.shrink();

    switch (_searchType) {
      case Song:
        widget = ValueListenableBuilder(
          valueListenable: _searchText,
          builder: (context, value, child) => SearchResultsWidget<Song>(
            key: UniqueKey(),
            searchText: _searchText.value,
            selectedMedia: _selectedSongs.value,
            onSongSelected: (songs) => _onSongSelected(songs),
          ),
        );

        break;
      case Album:
        widget = ValueListenableBuilder(
          valueListenable: _searchText,
          builder: (context, value, child) => SearchResultsWidget<Album>(
            key: UniqueKey(),
            searchText: _searchText.value,
            selectedMedia: _selectedSongs.value,
            onSongSelected: (songs) => _onSongSelected(songs),
          ),
        );
        break;
      case Artist:
        widget = ValueListenableBuilder(
          valueListenable: _searchText,
          builder: (context, value, child) => SearchResultsWidget<Artist>(
            key: UniqueKey(),
            searchText: _searchText.value,
            selectedMedia: _selectedSongs.value,
            onSongSelected: (songs) => _onSongSelected(songs),
          ),
        );
        break;
      default:
        break;
    }

    return widget;
  }

  Widget _buildButtonBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceBetween,
        children: [
          PlaylistButtonWidget(
            icon: const Icon(
              Icons.delete_sweep,
              size: 24.5,
            ),
            text: 'Reset',
            onPressed: () => _onResetPressed(),
          ),
          PlaylistButtonWidget(
            icon: const Icon(
              Icons.arrow_forward,
              size: 24.5,
            ),
            text: 'Next',
            onPressed: () => _onNextPressed(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSongs() {
    return ValueListenableBuilder(
      valueListenable: _selectedSongs,
      builder: (context, songs, child) => SelectedSongsWidget(
        count: songs.length,
      ),
    );
  }

  void _scrollToTopPressed() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onSearchResultsViewScroll() {
    _canScrollToTop.value = _scrollController.position.extentBefore > 320;
  }

  void _searchForMedia(String text) async {
    _debouncer.run(
      (_) async {
        _searchText.value = text.isEmpty ? null : text;
      },
    );
  }

  void _onSongSelected(List<Song> songs) {
    _selectedSongs.value = songs;
  }

  void _onResetPressed() {
    _selectedSongs.value.clear();
  }

  void _onNextPressed() {
    if (_selectedSongs.value.isNotEmpty) {
      PageNavigator.navigateTo(
        context,
        EditPlaylistWidget(
          playlist: Playlist(
            id: -1,
            date: '',
            name: 'New Playlist',
            tracks: _selectedSongs.value.length,
            songs: _selectedSongs.value
                .map((song) => PlaylistSong(song: song, isPlaying: false))
                .toList(),
          ),
        ),
      );
    } else {
      SnackbarHelper.showMessage(
        context,
        SnackbarType.information,
        'No songs selected',
      );
    }
  }

  void _onSearchTypeChanged(dynamic type) {
    _searchType = type;
    setState(() {});
  }
}
