import 'dart:typed_data';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:boombox/playlist-component/models/playlist_song_model.dart';
import 'package:boombox/playlist-component/services/playlist_service.dart';
import 'package:boombox/playlist-component/widgets/edit/edit_playlist_header.dart';
import 'package:boombox/playlist-component/widgets/edit/edit_playlist_song_view.dart';
import 'package:boombox/playlist-component/widgets/playlist_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPlaylistWidget extends StatefulWidget {
  final Playlist playlist;
  final void Function(Uint8List? image, String name, List<PlaylistSong> songs)?
      onSaveChangesPressed;
  final void Function()? onDiscardChangesPressed;

  const EditPlaylistWidget({
    super.key,
    required this.playlist,
    this.onSaveChangesPressed,
    this.onDiscardChangesPressed,
  });

  @override
  State<EditPlaylistWidget> createState() => _EditPlaylistWidgetState();
}

class _EditPlaylistWidgetState extends State<EditPlaylistWidget> {
  final String _title = 'Edit';

  late ScrollController _scrollController;
  final ValueNotifier _canScrollToTop = ValueNotifier(false);

  Uint8List? _image;
  String? _name;
  List<PlaylistSong>? _songs;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() => _onPlaylistViewScroll());
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
          appBar: AppBarWidget<EditPlaylistWidget>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildEditPlaylistScaffold(),
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

  Widget _buildEditPlaylistScaffold() {
    return Column(
      children: [
        Expanded(
          child: _buildPlaylistHeader(),
        ),
        _buildButtonBar(),
      ],
    );
  }

  Widget _buildPlaylistHeader() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          EditPlaylistHeaderWidget(
              playlist: widget.playlist,
              onHeaderUpdated: (image, name) => _onHeaderUpdated(image, name)),
          EditPlaylistSongViewWidget(
            songs: widget.playlist.songs,
            onSongsUpdated: (List<PlaylistSong> songs) =>
                _onSongsUpdated(songs),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceBetween,
        children: [
          PlaylistButtonWidget(
            icon: const Icon(
              Icons.delete,
              size: 24.5,
            ),
            text: 'Discard',
            onPressed: () async => _onDiscardChangesPressed(),
          ),
          PlaylistButtonWidget(
            icon: const Icon(
              Icons.save,
              size: 24.5,
            ),
            text: 'Save',
            onPressed: () async => _onSaveChangesPressed(),
          ),
        ],
      ),
    );
  }

  void _onDiscardChangesPressed() async {
    PageNavigator.navigateBack(context);
  }

  void _onSaveChangesPressed() async {
    if ((_name ?? '').isNotEmpty && _songs!.isNotEmpty) {
      if (widget.playlist.id < 0) {
        final bool wasSuccessful =
            await Provider.of<PlaylistService>(context, listen: false)
                .addPlaylistAsync(_image, _name!, _songs!.length, _songs!);

        if (mounted) {
          SnackbarHelper.showProviderResult(
            context,
            wasSuccessful,
            message:
                wasSuccessful ? 'Playlist Added' : 'Failed To Add Playlist',
          );
          PageNavigator.navigateBack(context);
        }
      } else {
        if (widget.onSaveChangesPressed != null) {
          widget.onSaveChangesPressed!(_image, _name!, _songs!);
        }
      }
    }
  }

  void _scrollToTopPressed() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onPlaylistViewScroll() {
    _canScrollToTop.value = _scrollController.position.extentBefore > 320;
  }

  void _onHeaderUpdated(Uint8List? image, String name) {
    _image = image;
    _name = name;
  }

  void _onSongsUpdated(List<PlaylistSong> songs) {
    _songs = songs;
  }
}
