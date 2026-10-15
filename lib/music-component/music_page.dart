import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/music-component/music_barrel.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<StatefulWidget> createState() => _MusicPage();
}

class _MusicPage extends State<MusicPage> with SingleTickerProviderStateMixin {
  final String _title = 'All Music';

  late AnimationController _modalController;

  late List<MusicCategoryFilter> lsCategories;
  late String _selectedCategory;

  final ValueNotifier<bool> _isSearchOpen = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isCategoryScrolling = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPlayerHidden = ValueNotifier<bool>(false);

  final ValueNotifier<MapEntry<String?, SortOptionOrder>> _songSortOrder =
      ValueNotifier<MapEntry<String?, SortOptionOrder>>(
          const MapEntry(null, SortOptionOrder.none));
  final ValueNotifier<MapEntry<String?, SortOptionOrder>> _albumSortOrder =
      ValueNotifier<MapEntry<String?, SortOptionOrder>>(
          const MapEntry(null, SortOptionOrder.none));
  final ValueNotifier<MapEntry<String?, SortOptionOrder>> _artistSortOrder =
      ValueNotifier<MapEntry<String?, SortOptionOrder>>(
          const MapEntry(null, SortOptionOrder.none));

  late List<Song> lsSongs;
  late List<Album> lsAlbums;
  late List<Artist> lsArtists;
  late List<Folder> lsFolders;

  Song? _addToPlaylist;

  @override
  void initState() {
    super.initState();

    _modalController = BottomSheet.createAnimationController(this);
    // Animation duration for displaying the BottomSheet
    _modalController.duration = const Duration(milliseconds: 400);
    // Animation duration for retracting the BottomSheet
    _modalController.reverseDuration = const Duration(milliseconds: 400);
    // Set animation curve duration for the BottomSheet
    _modalController.drive(CurveTween(curve: Curves.elasticInOut));

    lsCategories = [
      MusicCategoryFilter(text: 'Songs'),
      MusicCategoryFilter(text: 'Albums', isSelected: true),
      MusicCategoryFilter(text: 'Artists'),
      MusicCategoryFilter(text: 'Folders'),
    ];
    _selectedCategory = lsCategories
        .firstWhere(
          (category) => category.isSelected!,
          orElse: () => lsCategories.first,
        )
        .text;
  }

  @override
  void dispose() {
    _modalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<MusicPage>(
            title: _title,
            actions: _buildSortAction(),
          ),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildMusicLibrary(),
          ),
          resizeToAvoidBottomInset: true,
        ),
      ),
    );
  }

  Widget _buildMusicLibrary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMusicCategories()),
            _buildSearchIcon(),
          ],
        ),
        _buildSearchBar(),
        Consumer<MusicService>(
          builder: (context, service, child) => Expanded(
            child: _buildCategoryDisplay(service),
          ),
        ),
        _buildPopupMiniPlayer(),
      ],
    );
  }

  Widget _buildSearchIcon() {
    return ValueListenableBuilder(
      valueListenable: _isCategoryScrolling,
      builder: (context, isScrolling, child) => AnimatedSwitcher(
        transitionBuilder: (child, animation) => SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
            reverseCurve: Curves.bounceInOut,
          ).drive(
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: const Offset(0.0, 0.0),
            ),
          ),
          child: child,
        ),
        duration: const Duration(milliseconds: 8000),
        child: isScrolling && !_isSearchOpen.value
            ? SizedBox.shrink(key: UniqueKey())
            : SearchIconWidget(
                key: UniqueKey(),
                isSearchOpen: _isSearchOpen.value,
                isSearchSelected: (isSelected) => _isSearchSelected(isSelected),
              ),
      ),
    );
  }

  Widget _buildMusicCategories() {
    double maxHeight = MediaQuery.of(context).size.height * 0.06;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: NotificationListener<ScrollStartNotification>(
          child: NotificationListener<ScrollEndNotification>(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: lsCategories.length,
              itemBuilder: (context, index) {
                return MusicCategoryWidget(
                  category: lsCategories.elementAt(index),
                  onCategorySelected: (category) =>
                      _onCategorySelected(category),
                );
              },
            ),
            onNotification: (notification) =>
                _onMusicCategoryScroll(notification),
          ),
          onNotification: (notification) =>
              _onMusicCategoryScroll(notification),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ValueListenableBuilder(
      valueListenable: _isSearchOpen,
      builder: (context, isSelected, child) => AnimatedSwitcher(
        transitionBuilder: (child, animation) => SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
            reverseCurve: Curves.bounceInOut,
          ).drive(
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: const Offset(0.0, 0.0),
            ),
          ),
          child: child,
        ),
        duration: const Duration(milliseconds: 8000),
        child: isSelected
            ? SearchBarWidget(
                onFocusStatusChanged: (isFocused) =>
                    _onSearchBarFocusChanged(isFocused),
              )
            : SizedBox.shrink(key: UniqueKey()),
      ),
    );
  }

  Widget _buildCategoryDisplay(MusicService service) {
    Widget display;

    switch (_selectedCategory) {
      case 'Songs':
        display = ValueListenableBuilder(
          valueListenable: _songSortOrder,
          builder: (context, map, child) => FutureBuilder(
            future: service.getSongsAsync(map),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data!.isNotEmpty) {
                  return SongViewWidget(
                    songs: snapshot.data!,
                    onSongSelected: (index) =>
                        _onSongSelected(snapshot.data!.elementAt(index)),
                    onAddSongToPlaylistPressed: (index) async =>
                        _onAddSongToPlaylistPressed(
                      snapshot.data!.elementAt(index),
                    ),
                  );
                } else {
                  return const NoMusicWidget();
                }
              } else {
                return const CircularProgressIndicatorWidget();
              }
            },
          ),
        );
        break;
      case 'Albums':
        display = ValueListenableBuilder(
          valueListenable: _albumSortOrder,
          builder: (context, map, child) => FutureBuilder(
            future: service.getAlbumsAsync(map),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data!.isNotEmpty) {
                  return AlbumViewWidget(
                    albums: snapshot.data!,
                    onAlbumSelected: (id) => _onAlbumSelected(id),
                  );
                } else {
                  return const NoMusicWidget();
                }
              } else {
                return const CircularProgressIndicatorWidget();
              }
            },
          ),
        );
        break;
      case 'Artists':
        display = ValueListenableBuilder(
          valueListenable: _artistSortOrder,
          builder: (context, map, child) => FutureBuilder(
            future: service.getArtistsAsync(map),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data!.isNotEmpty) {
                  return ArtistViewWidget(
                    artists: snapshot.data!,
                    onArtistSelected: (id) => _onArtistSelected(id),
                  );
                } else {
                  return const NoMusicWidget();
                }
              } else {
                return const CircularProgressIndicatorWidget();
              }
            },
          ),
        );

        break;
      case 'Folders':
        display = FutureBuilder(
          future: service.getFoldersAsync(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.isNotEmpty) {
                return FolderViewWidget(
                  folders: snapshot.data!,
                  onFolderSelected: (path) => _onFolderSelected(path),
                );
              } else {
                return const NoMusicWidget();
              }
            } else {
              return const CircularProgressIndicatorWidget();
            }
          },
        );
        break;
      default:
        display = const NoMusicWidget();
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: display,
    );
  }

  Widget _buildPopupMiniPlayer() {
    return ValueListenableBuilder(
      valueListenable: _isPlayerHidden,
      builder: (context, isHidden, child) => StreamBuilder(
        stream: Provider.of<PlayerService>(context).getSequenceStateStream,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.hasData && !isHidden) {
            final TrackInfo? info =
                snapshot.data!.currentSource?.tag as TrackInfo?;
            if (!info.isNull) {
              child = PopupMiniPlayerWidget(
                song: info!,
                onShouldHidePressed: (shouldHide) =>
                    _onShouldHidePressed(shouldHide),
                onNavigatorToPlayerPressed: () => _navigateTo<PlayerPage>(
                  const PlayerPage(),
                  direction: TransitionDirection.btt,
                ),
              );
            } else {
              child = const SizedBox.shrink();
            }
          } else {
            child = const SizedBox.shrink();
          }

          return AnimatedSwitcher(
            transitionBuilder: (child, animation) => SlideTransition(
              position: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
                reverseCurve: Curves.easeOut,
              ).drive(
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ),
              ),
              child: child,
            ),
            duration: const Duration(milliseconds: 400),
            reverseDuration: const Duration(milliseconds: 400),
            child: child,
          );
        },
      ),
    );
  }

  void _onCategorySelected(String category) {
    List<MusicCategoryFilter> categories = [];
    for (MusicCategoryFilter filter in lsCategories) {
      filter.isSelected = (filter.text == category);
      categories.add(filter);
    }
    lsCategories = categories;
    _selectedCategory = category;
    setState(() {});
  }

  bool _onMusicCategoryScroll(ScrollNotification notification) {
    const bool isNotificationHandled = true;

    if (notification is ScrollStartNotification) {
      _isCategoryScrolling.value = true;
    } else if (notification is ScrollEndNotification) {
      _isCategoryScrolling.value = false;
    }

    return isNotificationHandled;
  }

  void _onAlbumSelected(int id) {}

  void _onSongSelected(Song song) async {
    _isPlayerHidden.value = false;
    await Provider.of<PlayerService>(
      context,
      listen: false,
    ).playSingleTrackAsync(song);
  }

  void _onAddSongToPlaylistPressed(Song song) async {
    _addToPlaylist = song;
    await BottomSheetModalHelper.showModal(context,
        child: _buildAddToPlaylistModal());
  }

  void _onArtistSelected(int id) {}

  void _onFolderSelected(String path) {}

  void _isSearchSelected(bool isSelected) {
    _isSearchOpen.value = isSelected;
  }

  void _onSearchBarFocusChanged(bool isFocused) {}

  Widget _buildAddToPlaylistModal() {
    return PlaylistsWidget(
      isParentModal: true,
      onPlaylistSelected: (playlist) async => _onPlaylistSelected(playlist),
    );
  }

  void _onPlaylistSelected(Playlist playlist) async {
    bool wasSuccessful = await Provider.of<PlaylistService>(
      context,
      listen: false,
    ).addSongToPlaylistAsync(playlist, _addToPlaylist!);

    if (mounted) {
      SnackbarHelper.showProviderResult(
        context,
        wasSuccessful,
        message: 'Song added to playlist.',
      );
    }
  }

  Widget _buildSortAction() {
    return GestureDetector(
      child: const Icon(Icons.filter_alt_sharp),
      onTap: () async => await BottomSheetModalHelper.showModal(
        context,
        transitionController: _modalController,
        child: _buildSortTypeModal(),
      ),
    );
  }

  Widget _buildSortTypeModal() {
    switch (_selectedCategory) {
      case 'Songs':
        return SortModalWidget<SongViewWidget>(
          order: _songSortOrder.value,
          onOrderChanged: (option, order) => _onSongOrderChanged(option, order),
        );
      case 'Albums':
        return SortModalWidget<AlbumViewWidget>(
          order: _songSortOrder.value,
          onOrderChanged: (option, order) =>
              _onAlbumOrderChanged(option, order),
        );
      case 'Artists':
        return SortModalWidget<ArtistViewWidget>(
          order: _artistSortOrder.value,
          onOrderChanged: (option, order) =>
              _onArtistOrderChanged(option, order),
        );
      default:
        return const NoSortOptionsModalWidget();
    }
  }

  void _onSongOrderChanged(String option, SortOptionOrder order) {
    _songSortOrder.value = MapEntry(option, order);
  }

  void _onAlbumOrderChanged(String option, SortOptionOrder order) {
    _albumSortOrder.value = MapEntry(option, order);
  }

  void _onArtistOrderChanged(String option, SortOptionOrder order) {
    _artistSortOrder.value = MapEntry(option, order);
  }

  _onShouldHidePressed(bool shouldHide) {
    _isPlayerHidden.value = shouldHide;
  }

  void _navigateTo<T>(
    Widget widget, {
    TransitionDirection direction = TransitionDirection.ltr,
  }) {
    PageNavigator.navigateTo<T>(
      context,
      widget,
      direction: direction,
      useScheduler: false,
    );
  }
}
