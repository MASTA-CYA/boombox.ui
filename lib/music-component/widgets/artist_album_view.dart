import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/services/music_service.dart';
import 'package:boombox/music-component/widgets/album_view.dart';
import 'package:boombox/music-component/widgets/artist_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtistAlbumWidget extends StatefulWidget {
  final String image;
  final Artist artist;

  const ArtistAlbumWidget({
    super.key,
    required this.image,
    required this.artist,
  });

  @override
  State<StatefulWidget> createState() => _ArtistAlbumWidget();
}

class _ArtistAlbumWidget extends State<ArtistAlbumWidget> {
  final String _title = 'Albums';

  late ScrollController _scrollController;
  final ValueNotifier _canScrollToTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() => _onAlbumPageScroll());
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<ArtistAlbumWidget>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildArtistAlbums(),
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
          resizeToAvoidBottomInset: true,
        ),
      ),
    );
  }

  Widget _buildArtistAlbums() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildArtistHeader(),
          _buildAlbums(),
        ],
      ),
    );
  }

  Widget _buildArtistHeader() {
    return ArtistHeaderWidget(
      image: widget.image,
      artist: widget.artist,
    );
  }

  Widget _buildAlbums() {
    return FutureBuilder(
      future: Provider.of<MusicService>(
        context,
        listen: false,
      ).getAlbumsByArtistAsync(widget.artist.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AlbumViewWidget(
            albums: snapshot.data!,
            onAlbumSelected: (id) => {},
          );
        } else {
          return const CircularProgressIndicatorWidget();
        }
      },
    );
  }

  void _scrollToTopPressed() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onAlbumPageScroll() {
    _canScrollToTop.value = _scrollController.position.extentBefore > 320;
  }
}
